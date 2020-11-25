Pod::Spec.new do |spec|
  
  spec.name         = "NaveggSdkIOS"
  spec.version      = "1.1.7"
  spec.summary      = "Library used in the tracker users."
  spec.description  = "Library to tracker, custom, segments and onBoarding" 

  spec.homepage     = "https://github.com/Navegg/navegg-ios"

  spec.license      = { :type => "Apache", :file => "LICENSE" }

  spec.author             = { "Navegg" => "it@navegg.com" }

  spec.module_name = "SdkNaveggIOS"

  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5.0"

  spec.source = { :git => "https://github.com/Navegg/navegg-ios.git", :tag => spec.version.to_s }

  spec.source_files  = "SdkNaveggIOS", "SdkNaveggIOS/**/*.{h,m,swift}"

  spec.requires_arc = true
  
  spec.dependency 'Alamofire', '~> 4.9.0'
  spec.dependency 'SwiftProtobuf', '~> 1.12.0'
  spec.dependency 'ReachabilitySwift', '~> 5.0.0'

end
