# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Neves' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Moya'
  pod 'Moya/RxSwift'
  pod 'Moya/ReactiveSwift'
  pod 'RxCocoa'
  pod 'WCDB'
  pod 'Kingfisher'
#  pod 'KingfisherWebP'
  pod 'SwiftyJSON'
  pod 'KakaJSON'
  pod 'lottie-ios', '~> 3.5.0'
  pod 'SnapKit', '~> 5.7.1'
#  pod 'RealmSwift'
  pod 'SwiftGen'
  pod 'FunnyButton', '~> 0.1.5'

# OC的库
  pod 'pop'
  pod 'YYText'
  pod 'MJRefresh'
  pod 'SVProgressHUD'
  pod 'AFNetworking'
  pod 'JPImageresizerView'
  pod 'MMKV'#, '~> 1.2.14'
  pod 'libpag'
  
  pod 'LookinServer', :configurations => ['Debug']
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
  
end
