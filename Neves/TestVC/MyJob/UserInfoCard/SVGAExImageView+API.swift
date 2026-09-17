//
//  SVGAExImageView+API.swift
//  Falla
//
//  Created by aa on 2025/12/9.
//

import UIKit

// MARK: - image
extension SVGAExImageView {
    @objc func updateUI(image: UIImage?) {
        updateUI(image: image, animated: false)
    }
    
    @objc func updateUI(image: UIImage?, animated: Bool) {
        guard let image else {
            clean(animated: animated)
            return
        }
        updateUI(source: .image(image), animated: animated)
    }
}

// MARK: - image name
extension SVGAExImageView {
    @objc func updateUI(imageName: String?) {
        updateUI(imageName: imageName, animated: false)
    }
    
    @objc func updateUI(imageName: String?, animated: Bool) {
        guard let imageName else {
            clean(animated: animated)
            return
        }
        updateUI(source: .asset(imageName), animated: animated)
    }
}

// MARK: - image url
extension SVGAExImageView {
    @objc func updateUI(imageUrl: String?, placeholder: UIImage?) {
        updateUI(imageUrl: imageUrl, isGrayscale: false, isSweep: false, placeholder: placeholder, animated: false)
    }
    
    @objc func updateUI(imageUrl: String?, placeholder: UIImage?, animated: Bool) {
        updateUI(imageUrl: imageUrl, isGrayscale: false, isSweep: false, placeholder: placeholder, animated: animated)
    }
    
    @objc func updateUI(imageUrl: String?, isSweep: Bool, placeholder: UIImage?, animated: Bool) {
        updateUI(imageUrl: imageUrl, isGrayscale: false, isSweep: isSweep, placeholder: placeholder, animated: animated)
    }
    
    @objc func updateUI(imageUrl: String?, isGrayscale: Bool, placeholder: UIImage?, animated: Bool) {
        updateUI(imageUrl: imageUrl, isGrayscale: isGrayscale, isSweep: false, placeholder: placeholder, animated: animated)
    }
    
    @objc func updateUI(imageUrl: String?, isGrayscale: Bool, isSweep: Bool, placeholder: UIImage?, animated: Bool) {
        guard let imageUrl else {
            clean(animated: animated)
            return
        }
        updateUI(source: .remote(imageUrl, isGrayscale, isSweep, placeholder), animated: animated)
    }
}

// MARK: - svga url
extension SVGAExImageView {
    @objc func updateUI(svgaUrl: String?) {
        updateUI(svgaUrl: svgaUrl, isGrayscale: false, placeholder: nil, animated: false)
    }
    
    @objc func updateUI(svgaUrl: String?, animated: Bool) {
        updateUI(svgaUrl: svgaUrl, isGrayscale: false, placeholder: nil, animated: animated)
    }
    
    @objc func updateUI(svgaUrl: String?, placeholder: UIImage?, animated: Bool) {
        updateUI(svgaUrl: svgaUrl, isGrayscale: false, placeholder: placeholder, animated: animated)
    }
    
    @objc func updateUI(svgaUrl: String?, isGrayscale: Bool, animated: Bool) {
        updateUI(svgaUrl: svgaUrl, isGrayscale: isGrayscale, placeholder: nil, animated: animated)
    }
    
    @objc func updateUI(svgaUrl: String?, isGrayscale: Bool, placeholder: UIImage?, animated: Bool) {
        guard let svgaUrl else {
            clean(animated: animated)
            return
        }
        updateUI(source: .svga(svgaUrl, isGrayscale, placeholder), animated: animated)
    }
}

// MARK: - common url
extension SVGAExImageView {
    @objc func updateUI(url: String?, animated: Bool) {
        updateUI(url: url, isGrayscale: false, placeholder: nil, animated: animated)
    }
    
    @objc func updateUI(url: String?, placeholder: UIImage?) {
        updateUI(url: url, isGrayscale: false, placeholder: placeholder, animated: false)
    }
    
    @objc func updateUI(url: String?, placeholder: UIImage?, animated: Bool) {
        updateUI(url: url, isGrayscale: false, placeholder: placeholder, animated: animated)
    }
    
    @objc func updateUI(url: String?, isGrayscale: Bool) {
        updateUI(url: url, isGrayscale: isGrayscale, placeholder: nil, animated: false)
    }
    
    @objc func updateUI(url: String?, isGrayscale: Bool, animated: Bool) {
        updateUI(url: url, isGrayscale: isGrayscale, placeholder: nil, animated: animated)
    }
    
    @objc func updateUI(url: String?, isGrayscale: Bool, placeholder: UIImage?, animated: Bool) {
        if let url, url.hasSuffix(".svga") {
            updateUI(svgaUrl: url, isGrayscale: isGrayscale, placeholder: placeholder, animated: animated)
        } else {
            updateUI(imageUrl: url, isGrayscale: isGrayscale, isSweep: false, placeholder: placeholder, animated: animated)
        }
    }
}
