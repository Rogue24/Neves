//
//  DeepLabV3ViewController.swift
//  Neves
//
//  Created by aa on 2024/10/22.
//

import UIKit
import FunnyButton
import CoreML

class DeepLabV3ViewController: TestBaseViewController {
    
    lazy var model = try! DeepLabV3(configuration: {
        let config = MLModelConfiguration()
        config.allowLowPrecisionAccumulationOnGPU = true
        if #available(iOS 16.0, *) {
            config.computeUnits = .cpuAndNeuralEngine
        } else {
            // Fallback on earlier versions
        }
        return config
    }())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
        addFunnyAction {
            JPrint("DeepLabV3 test")
        }
    }
    
}
