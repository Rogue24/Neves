//
//  KingfisherTestViewController.swift
//  Neves
//
//  Created by aa on 2021/6/10.
//

class KingfisherTestViewController: TestBaseViewController {
    
    let imgView1 = UIImageView(frame: [0, NavTopMargin, PortraitScreenWidth, (PortraitScreenHeight - NavTopMargin - DiffTabBarH) * 0.5])
    let imgView2 = UIImageView(frame: [0, NavTopMargin + (PortraitScreenHeight - NavTopMargin - DiffTabBarH) * 0.5, PortraitScreenWidth, (PortraitScreenHeight - NavTopMargin - DiffTabBarH) * 0.5])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView1.backgroundColor = .randomColor
        imgView1.contentMode = .scaleAspectFit
        view.addSubview(imgView1)
        
        imgView2.backgroundColor = .randomColor
        imgView2.contentMode = .scaleAspectFit
        view.addSubview(imgView2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFunAction { [weak self] in
            guard let self = self else { return }
            self.test()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFunAction()
    }
    
    func test() {
        let url = LoremPicsum.photoURL(size: imgView1.frame.size, randomId: 1)
        
//        (_ receivedSize: Int64, _ totalSize: Int64)
        
        // MARK: - 【ImageProcessor】
        // 使用了 ImageProcessor 会有一个新的 identifier，用于区别同一张图片的不同处理结果
        // 每种不同（单个或组装）的 ImageProcessor 只对应处理过的图片，所以只保存处理的图片，不会同时保存原图
        var p: ImageProcessor = RoundCornerImageProcessor(cornerRadius: 999)
        p = p |> ResizingImageProcessor(referenceSize: [1000, 2000])
        // 这里写多少像素，获取到图像就真的多少像素，像素不够就补上的那种
        
        let c = FormatIndicatedCacheSerializer.png
        
        // MARK: - KingfisherManager.shared.downloader.downloadImage
        
        // downloadImage不会去缓存获取，每次都会重新下载，也不会缓存到磁盘中
        // 下载过程接收的是mutableData（可变Data），在内存中，并不是磁盘里面
        KingfisherManager.shared.downloader.downloadImage(with: url, options: [.processor(p)]) { a, b in
            JPrint("progress1", Double(a) / Double(b))
        } completionHandler: { [weak self] r in
            switch r {
            case let .success(imgResult):
                let image = imgResult.image
                JPrint("成功111", image.size, imgResult.url?.absoluteString ?? "")
                self?.imgView1.image = image

            case .failure(_):
                JPrint("失败111")
            }
        }
        
        
        // MARK: - KingfisherManager.shared.retrieveImage
        
        // retrieveImage才会缓存，有缓存（内存没有再去磁盘找）直接返回，没有就下载
        KingfisherManager.shared.retrieveImage(with: url, options: [.processor(p), .cacheSerializer(c)]) { a, b in
            JPrint("progress2", Double(a) / Double(b))
        } downloadTaskUpdated: { t in

        } completionHandler: { [weak self] r in
            switch r {
            case let .success(imgResult):
                let image = imgResult.image
                JPrint("成功222", image.size, imgResult.cacheType, imgResult.source.cacheKey, imgResult.originalSource.cacheKey)
                self?.imgView2.image = image

            case .failure(_):
                JPrint("失败222")
            }
        }
        
        
        // MARK: - ImagePrefetcher
        
        let urls = [
            LoremPicsum.photoURL(size: [400, 200], randomId: 1),
            LoremPicsum.photoURL(size: [400, 200], randomId: 2),
            LoremPicsum.photoURL(size: [400, 200], randomId: 3),
            LoremPicsum.photoURL(size: [400, 200], randomId: 4),
            LoremPicsum.photoURL(size: [400, 200], randomId: 5),
            LoremPicsum.photoURL(size: [400, 200], randomId: 6),
        ]
        
        /// - `skippedResources`: An array of resources that are already cached before the prefetching starting.
        /// - `skippedResources`: 在预取开始之前已经缓存的资源数组。
        ///
        /// - `failedResources`: An array of resources that fail to be downloaded. It could because of being cancelled while downloading, encountered an error when downloading or the download not being started at all.
        /// - `failedResources`:无法下载的资源数组。它可能是因为下载时被取消，下载时遇到错误或根本没有开始下载。
        ///
        /// - `completedResources`: An array of resources that are downloaded and cached successfully.
        /// - `completedResources`: 成功下载并缓存的资源数组。
        
        // s：在缓存获取到的（缓存获取到的就不会在c中了）
        // f：获取失败的
        // c：通过下载获取到的
        let imagePrefetcher = ImagePrefetcher(resources: urls, options: [.processor(p)]) { s, f, c in
            JPrint("progress ---", "s =", s.count, ", f =", f.count, ", c =", c.count)
        } completionHandler: { s, f, c in
            JPrint("completion ---", "s =", s.count, ", f =", f.count, ", c =", c.count)
        }
        imagePrefetcher.start()
        
    }
}
