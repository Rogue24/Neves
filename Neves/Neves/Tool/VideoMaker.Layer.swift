//
//  VideoMaker.Layer.swift
//  Neves
//
//  Created by aa on 2021/10/19.
//

import AVFoundation

extension VideoMaker {
    static func createVideoWriterInput(frameInterval: Int, size: CGSize) -> AVAssetWriterInput {
        let bitsPerSecond = 5000 * 1024
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: bitsPerSecond,
                AVVideoMaxKeyFrameIntervalKey: frameInterval,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            ]
        ]
        return AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    }
    
    
    static func makeVideo(framerate: Int,
                          frameInterval: Int,
                          duration: TimeInterval,
                          size: CGSize,
                          audioPath: String? = nil,
                          layerProvider: @escaping LayerProvider,
                          completion: @escaping Completion) {
        
        guard !Thread.isMainThread else {
            Asyncs.async {
                makeVideo(framerate: framerate,
                          frameInterval: frameInterval,
                          duration: duration,
                          size: size,
                          layerProvider: layerProvider,
                          completion: completion)
            }
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer { UIGraphicsEndImageContext() }
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        
        let videoName = "\(Int(Date().timeIntervalSince1970)).mp4"
        let videoPath = File.tmpFilePath(videoName)
        
        guard let videoWriter = try? AVAssetWriter(url: URL(fileURLWithPath: videoPath), fileType: .mp4) else {
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        
        videoWriter.shouldOptimizeForNetworkUse = false
        
        let writerInput = createVideoWriterInput(frameInterval: frameInterval, size: size)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
        
        guard videoWriter.canAdd(writerInput) else {
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        videoWriter.add(writerInput)
        
        guard videoWriter.startWriting() else {
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        videoWriter.startSession(atSourceTime: .zero)
        
        let timescale = CMTimeScale(framerate)
        
        let totalFrame = framerate * Int(duration)
        let frameCount = frameInterval * Int(duration)
        
        var lastFrame: Int = 0
        var lastPixelBuffer: CVPixelBuffer? = nil
        
        for i in 0 ... frameCount {
            
            let progress = CGFloat(i) / CGFloat(frameCount)
            let currentFrame = Int(CGFloat(totalFrame) * progress)
            let currentTime = duration * progress
            
            // 这里会有一定概率出现错误：Code=-11800 "The operation could not be completed"
            // 这是因为写入了相同的currentFrame造成的，所以要这里做判断，相同就跳过
            if lastFrame == currentFrame { continue }
            lastFrame = currentFrame
//            JPrint("progress", progress, ", currentFrame", currentFrame)
            
            while true {
                if adaptor.assetWriterInput.isReadyForMoreMediaData ||
                   videoWriter.status != .writing {
                    break
                }
            }
            if videoWriter.status != .writing {
                // 其中一个错误：Code=-11800 "The operation could not be completed"
                // 这是因为写入了相同的currentFrame造成的
                JPrint("失败？？？", videoWriter.status.rawValue,
                       videoWriter.error ?? "",
                       adaptor.assetWriterInput.isReadyForMoreMediaData)
                
                File.manager.deleteFile(videoPath)
                Asyncs.main { completion(.failure(.writerError)) }
                return
            }
            
            ctx.saveGState()
            var layers: [CALayer?] = []
            DispatchQueue.main.sync {
                layers = layerProvider(currentFrame, currentTime, size)
            }
            layers.forEach {
                guard let layer = $0 else { return }
                layer.render(in: ctx)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            ctx.clear(CGRect(origin: .zero, size: size))
            ctx.restoreGState()
            
            let pixelBuffer: CVPixelBuffer
            if let image = image, let pb = createPixelBufferWithImage(image, size: size) {
                lastPixelBuffer = pb
                pixelBuffer = pb
            } else {
                pixelBuffer = lastPixelBuffer ?? {
                    let pb = createPixelBufferWithImage(UIImage.jp_createImage(with: .black), size: size)!
                    lastPixelBuffer = pb
                    return pb
                }()
            }
            let frameTime = CMTime(value: CMTimeValue(currentFrame), timescale: timescale)
            adaptor.append(pixelBuffer, withPresentationTime: frameTime)
        }
        
        writerInput.markAsFinished()
        
        let endTime = CMTime(value: CMTimeValue(totalFrame), timescale: timescale)
        videoWriter.endSession(atSourceTime: endTime)
        
        let lock = DispatchSemaphore(value: 0)
        videoWriter.finishWriting { lock.signal() }
        lock.wait()
        
        switch videoWriter.status {
        case .completed:
            break
        default:
            File.manager.deleteFile(videoPath)
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        
        let cachePath = File.cacheFilePath(videoName)
        File.manager.deleteFile(cachePath)
        
        guard let audioPath = audioPath else {
            File.manager.moveFile(videoPath, toPath: cachePath)
            Asyncs.main { completion(.success(cachePath)) }
            return
        }
        
        let videoAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath))
        let audioAsset = AVURLAsset(url: URL(fileURLWithPath: audioPath))
        
        let videoDuration = videoAsset.duration
        
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first,
              let audioTrack = audioAsset.tracks(withMediaType: .audio).first else {
            File.manager.deleteFile(videoPath)
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        
        let mixComposition = AVMutableComposition()
        
        guard let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            File.manager.deleteFile(videoPath)
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoDuration), of: videoTrack, at: .zero)
            
            var audioDuration = audioAsset.duration
            if audioDuration > videoDuration {
                audioDuration = videoDuration
            }
            try compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: audioDuration), of: audioTrack, at: .zero)
        } catch {
            File.manager.deleteFile(videoPath)
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            File.manager.deleteFile(videoPath)
            Asyncs.main { completion(.failure(.writerError)) }
            return
        }
        exportSession.outputFileType = .mp4
        exportSession.outputURL = URL(fileURLWithPath: cachePath)
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            File.manager.deleteFile(videoPath)
            switch exportSession.status {
            case .completed:
                Asyncs.main { completion(.success(cachePath)) }
            default:
                Asyncs.main { completion(.failure(.writerError)) }
            }
        }
    }
}
