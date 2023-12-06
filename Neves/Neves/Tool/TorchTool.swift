//
//  TorchTool.swift
//  Neves
//
//  Created by aa on 2023/12/6.
//

import AVFoundation
import Combine

class TorchTool: ObservableObject {
    let camera: AVCaptureDevice
    
    @Published private(set) var isOpening: Bool
    
    private var cancellable: AnyCancellable?
    
    init(camera: AVCaptureDevice) {
        self.camera = camera
        self.isOpening = camera.torchMode != .off
        
        cancellable = NotificationCenter.default
                .publisher(for: UIApplication.didBecomeActiveNotification)
                .sink() { [weak self] _ in
                    guard let self = self else { return }
                    JPrint("hasTorch", self.camera.hasTorch)
                    JPrint("torchLevel", self.camera.torchLevel)
                    JPrint("isTorchAvailable", self.camera.isTorchAvailable)
                    JPrint("isTorchActive", self.camera.isTorchActive)
                    JPrint("torchMode", self.camera.torchMode.rawValue)
                    JPrint("-----------------------")
                    self.isOpening = self.camera.torchMode != .off
                }
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    // 开启闪光灯
    func open() {
        guard camera.hasTorch, camera.torchMode == .off else { return }
        do {
            try camera.lockForConfiguration()
            camera.torchMode = .on
            camera.unlockForConfiguration()
            isOpening = true
        } catch {
            
        }
    }
    
    // 关闭闪光灯
    func close() {
        guard camera.torchMode == .on else { return }
        do {
            try camera.lockForConfiguration()
            camera.torchMode = .off
            camera.unlockForConfiguration()
            isOpening = false
        } catch {
            
        }
    }
}
