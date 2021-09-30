//
//  ImageVideoMaker.swift
//  Neves
//
//  Created by aa on 2021/9/27.
//

import Lottie
import UIKit
import AVFoundation

class ImageVideoMaker {
    
    enum MakeError: Error {
        case writerError
    }
    
    struct ImageInfo {
        let image: UIImage
        let duration: TimeInterval
        var pixelBuffer: CVPixelBuffer? = nil
    }
    
    var videoSize: CGSize = [700, 700 / AspectRatio_16_9]
    var frameInterval = 15
    
    var pixelBufferMap: [Int: CVPixelBuffer] = [:]
    
    
    
    let maxConcurrentOperationCount: Int = 5
    
    func createVideo(with infos: [ImageInfo], completion: @escaping (Result<String, MakeError>) -> ()) {
        Asyncs.async {
            var imageInfos = infos
            
            let operationLock = DispatchSemaphore(value: 1)
            let concurrentLock = DispatchSemaphore(value: self.maxConcurrentOperationCount)
            
            DispatchQueue.concurrentPerform(iterations: imageInfos.count) { [weak self] i in
                guard let self = self else { return }
                
                concurrentLock.wait()
                defer { concurrentLock.signal() }
                
                operationLock.wait()
                var imageInfo = imageInfos[i]
                if imageInfo.pixelBuffer == nil, let pixelBuffer = Self.createPixelBufferWithImage(imageInfo.image, size: self.videoSize) {
                    imageInfo.pixelBuffer = pixelBuffer
                    imageInfos[i] = imageInfo
                }
                operationLock.signal()
            }
            
            Self.createVideoWithImageInfos(imageInfos, size: self.videoSize, frameInterval: self.frameInterval, completion: completion)
        }
    }
    
    
        
        

    
}

extension ImageVideoMaker {
    static func createPixelBufferWithImage(_ image: UIImage, size: CGSize) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        var keyCallBacks = kCFTypeDictionaryKeyCallBacks
        var valCallBacks = kCFTypeDictionaryValueCallBacks
        guard let empty = CFDictionaryCreate(kCFAllocatorDefault, nil, nil, 0, &keyCallBacks, &valCallBacks) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: empty,
        ]
        
        var pixelBuffer: CVPixelBuffer? = nil
        // 创建 pixel buffer
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(size.width),
                                         Int(size.height),
                                         kCVPixelFormatType_32BGRA,
                                         options as CFDictionary,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
            return nil
        }
        
        // 锁定 pixel buffer 的基地址
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        // 获取 pixel buffer 的基地址
        guard let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            // 解锁 pixel buffer
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            return nil
        }
        
        var bitmapRawValue = CGBitmapInfo.byteOrder32Little.rawValue
        let alphaInfo = cgImage.alphaInfo
        if alphaInfo == .premultipliedLast ||
            alphaInfo == .premultipliedFirst ||
            alphaInfo == .last ||
            alphaInfo == .first {
            bitmapRawValue |= CGImageAlphaInfo.premultipliedFirst.rawValue
        } else {
            bitmapRawValue |= CGImageAlphaInfo.noneSkipFirst.rawValue
        }
        
        // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
        guard let context = CGContext(data: pixelData,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: ColorSpace,
                                      bitmapInfo: bitmapRawValue) else {
            // 解锁 pixel buffer
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            return nil
        }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let rect: CGRect
        if (width > height) {
            let h = size.width * (height / width)
            rect = [0, HalfDiffValue(size.height, h), size.width, h]
        } else {
            let w = size.height * (width / height)
            rect = [HalfDiffValue(size.width, w), 0, w, size.height]
        }
        
        context.draw(cgImage, in: rect)
        
        // 解锁 pixel buffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    static func createVideoWithImageInfos(_ imageInfos: [ImageInfo], size: CGSize, frameInterval: Int, completion: @escaping (Result<String, MakeError>) -> ()) {
        
        let videoName = "\(Int(Date().timeIntervalSince1970)).mp4"
        let videoPath = File.tmpFilePath(videoName)
        
        guard let videoWriter = try? AVAssetWriter(url: URL(fileURLWithPath: videoPath), fileType: .mp4) else {
            completion(.failure(.writerError))
            return
        }
        
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
        
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
        
        guard videoWriter.canAdd(writerInput) else {
            completion(.failure(.writerError))
            return
        }
        
//        JPrint("000 ---", videoWriter.status.rawValue, adaptor.assetWriterInput.isReadyForMoreMediaData)
        videoWriter.add(writerInput)
//        JPrint("111 ---", videoWriter.status.rawValue, adaptor.assetWriterInput.isReadyForMoreMediaData);
        
//        JPrint("222 ---", videoWriter.status.rawValue, adaptor.assetWriterInput.isReadyForMoreMediaData);
        guard videoWriter.startWriting() else {
            completion(.failure(.writerError))
            return
        }
//        JPrint("333 ---", videoWriter.status.rawValue, adaptor.assetWriterInput.isReadyForMoreMediaData);
        
//        JPrint("444 ---", videoWriter.status.rawValue, adaptor.assetWriterInput.isReadyForMoreMediaData);
        videoWriter.startSession(atSourceTime: .zero)
//        JPrint("555 ---", videoWriter.status.rawValue, adaptor.assetWriterInput.isReadyForMoreMediaData);
        
        var currentFrame = 0
        let timescale = CMTimeScale(frameInterval)
        
        for imageInfo in imageInfos {
            guard let pixelBuffer = imageInfo.pixelBuffer else {
                completion(.failure(.writerError))
                return
            }
            
            let imageTotalFrame = Int(ceil(imageInfo.duration)) * frameInterval
            
            for _ in 0 ..< imageTotalFrame {
                while true {
                    if adaptor.assetWriterInput.isReadyForMoreMediaData || videoWriter.status != .writing {
//                        JPrint("xxx ---", videoWriter.status.rawValue, adaptor.assetWriterInput.isReadyForMoreMediaData);
                        break
                    }
                }
                
                if videoWriter.status != .writing {
                    completion(.failure(.writerError))
                    return
                }
                
                let currentTime = CMTime(value: CMTimeValue(currentFrame), timescale: timescale)
                adaptor.append(pixelBuffer, withPresentationTime: currentTime)
                currentFrame += 1
            }
        }
        
        writerInput.markAsFinished()
        
        let endTime = CMTime(value: CMTimeValue(currentFrame), timescale: timescale)
        videoWriter.endSession(atSourceTime: endTime)
        
        videoWriter.finishWriting {
            switch videoWriter.status {
            case .completed:
                let cachePath = File.cacheFilePath(videoName)
                File.manager.deleteFile(cachePath)
                File.manager.moveFile(videoPath, toPath: cachePath)
                File.manager.deleteFile(videoPath)
                completion(.success(cachePath))
                
            default:
                completion(.failure(.writerError))
            }
        }
    }
}
