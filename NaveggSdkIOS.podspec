Pod::Spec.new do |spec|
  
  spec.name         = "NaveggSdkIOS"
  spec.version      = "1.1.4"
  spec.summary      = "Library used in the tracker users."
  spec.description  = "Library to tracker, custom, segments and onBoarding" 

  spec.homepage     = "https://github.com/Navegg/navegg-ios"

  spec.license      = { :type => "Apache", :file => "LICENSE" }

  spec.author             = { "Navegg" => "it@navegg.com" }

  spec.module_name = "SdkNaveggIOS"

  spec.ios.deployment_target = "8.0"
  spec.swift_version = "4.2"

  spec.source = { :git => "https://github.com/Navegg/navegg-ios.git", :tag => spec.version.to_s }

  spec.source_files  = "SdkNaveggIOS", "SdkNaveggIOS/**/*.{h,m,swift}"

  spec.requires_arc = true
  
  spec.dependency 'Alamofire', '~> 4.7.3'
  spec.dependency 'SwiftProtobuf', '~> 1.2.0'
  spec.dependency 'ReachabilitySwift', '~> 4.3.0'

end
