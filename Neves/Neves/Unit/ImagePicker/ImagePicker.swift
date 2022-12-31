//
//  ImagePicker.swift
//  ImagePickerDemo
//
//  Created by aa on 2022/12/29.
//

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

enum ImagePicker {
    // MARK: - ImagePicker.PickType
    enum PickType {
        case photo // 照片
        case video // 视频
        case all // 图片+视频
        
        var types: [String] {
            if #available(iOS 14.0, *) {
                switch self {
                case .photo:
                    return [
                        UTType.image.identifier,
                        UTType.livePhoto.identifier,
                    ]
                case .video:
                    return [
                        UTType.movie.identifier,
                        UTType.video.identifier,
                    ]
                case .all:
                    return [
                        UTType.movie.identifier,
                        UTType.video.identifier,
                        UTType.image.identifier,
                        UTType.livePhoto.identifier,
                    ]
                }
            } else {
                switch self {
                case .photo:
                    return [
                        kUTTypeImage as String,
                        kUTTypeLivePhoto as String,
                    ]
                case .video:
                    return [
                        kUTTypeMovie as String,
                        kUTTypeVideo as String,
                    ]
                case .all:
                    return [
                        kUTTypeMovie as String,
                        kUTTypeVideo as String,
                        kUTTypeImage as String,
                        kUTTypeLivePhoto as String,
                    ]
                }
            }
            
        }
    }
    
    // MARK: - ImagePicker.Completion
    typealias Completion<T: ImagePickerObject> = (_ result: Result<T, ImagePicker.PickError>) -> Void
    
    // MARK: - ImagePicker.PickError
    enum PickError: Error {
        case nullParentVC // 没有父控制器
        case objFetchFaild // obj查找失败
        case objConvertFaild(_ error: Error?) // obj转换失败
        case other(_ error: Error?) // 其他错误
        case userCancel // 用户取消
        
        func log() {
            switch self {
            case .nullParentVC:
                print("jpjpjp 没有父控制器")
            case .objFetchFaild:
                print("jpjpjp obj查找失败")
            case let .objConvertFaild(error):
                print("jpjpjp obj转换失败：\(String(describing: error))")
            case let .other(error):
                print("jpjpjp 其他错误：\(String(describing: error))")
            case .userCancel:
                print("jpjpjp 用户取消")
            }
        }
    }
}

// MARK: - ImagePicker.Controller
extension ImagePicker {
    class Controller<T: ImagePickerObject>: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private var result: Result<T, ImagePicker.PickError>? = nil
        private let locker = DispatchSemaphore(value: 0)
        private var isLocking = false
        
        // MARK: Life cycle
        deinit {
            print("jpjpjp ImagePicker.Controller deinit")
        }
        
        // MARK: UIImagePickerControllerDelegate
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 获取结果
            do {
                result = .success(try T.fetchFromPicker(info))
            } catch let pickError as ImagePicker.PickError {
                result = .failure(pickError)
            } catch {
                result = .failure(.other(error))
            }
            
            // 解锁，抛出结果
            tryUnlock()
            
            // 关闭控制器
            dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // 解锁
            tryUnlock()
            
            // 关闭控制器
            dismiss(animated: true)
        }
    }
}

// MARK: - Open album
extension ImagePicker.Controller {
    static func openAlbum<T: ImagePickerObject>(_ mediaType: ImagePicker.PickType) async throws -> T {
        let picker: ImagePicker.Controller<T> = try showAlbumPicker(mediaType: mediaType)
        return try await picker.pickObject()
    }
    
    static func openAlbum<T: ImagePickerObject>(_ mediaType: ImagePicker.PickType, completion: @escaping ImagePicker.Completion<T>) {
        do {
            let picker: ImagePicker.Controller<T> = try showAlbumPicker(mediaType: mediaType)
            picker.pickObject(completion: completion)
        } catch let pickError as ImagePicker.PickError {
            completion(.failure(pickError))
        } catch {
            completion(.failure(.other(error)))
        }
    }
}

// MARK: - Photograph
extension ImagePicker.Controller {
    static func photograph() async throws -> UIImage {
        let picker = try showPhotographPicker()
        return try await picker.pickObject()
    }
    
    static func photograph(completion: @escaping ImagePicker.Completion<UIImage>) {
        do {
            let picker = try showPhotographPicker()
            picker.pickObject(completion: completion)
        } catch let pickError as ImagePicker.PickError {
            completion(.failure(pickError))
        } catch {
            completion(.failure(.other(error)))
        }
    }
}

// MARK: - Show picker
private extension ImagePicker.Controller {
    static func showAlbumPicker<T>(mediaType: ImagePicker.PickType) throws -> ImagePicker.Controller<T> {
        guard let parentVC = UIApplication.shared.delegate?.window??.rootViewController else {
            throw ImagePicker.PickError.nullParentVC
        }
        let picker = ImagePicker.Controller<T>()
        picker.modalPresentationStyle = .overFullScreen
        picker.mediaTypes = mediaType.types
        picker.videoQuality = .typeHigh
        picker.delegate = picker
        parentVC.present(picker, animated: true)
        return picker
    }
    
    static func showPhotographPicker() throws -> ImagePicker.Controller<UIImage> {
        guard let parentVC = UIApplication.shared.delegate?.window??.rootViewController else {
            throw ImagePicker.PickError.nullParentVC
        }
        let picker = ImagePicker.Controller<UIImage>()
        picker.modalPresentationStyle = .overFullScreen
        picker.sourceType = .camera
        picker.delegate = picker
        parentVC.present(picker, animated: true)
        return picker
    }
}

// MARK: - Pick object handle
private extension ImagePicker.Controller {
    func pickObject() async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            pickObject() { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func pickObject(completion: @escaping ImagePicker.Completion<T>) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(.userCancel))
                }
                return
            }
            
            // 加锁，等待代理方法的触发
            self.tryLock()
            
            // 来到这里就是已经获取结果or用户点击取消，
            // 回到主线程将结果抛出。
            DispatchQueue.main.async {
                completion(self.result ?? .failure(.userCancel))
            }
        }
    }
}

// MARK: - Lock & Unlock
private extension ImagePicker.Controller {
    @discardableResult
    func tryLock() -> Bool {
        guard !isLocking else { return isLocking }
        guard !Thread.isMainThread else { return isLocking }
        isLocking = true
        locker.wait()
        return isLocking
    }
    
    @discardableResult
    func tryUnlock() -> Bool {
        guard Thread.isMainThread else { return !isLocking }
        guard isLocking else { return !isLocking }
        isLocking = false
        locker.signal()
        return !isLocking
    }
}
