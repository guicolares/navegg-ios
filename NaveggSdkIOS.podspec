Pod::Spec.new do |s|

s.name = "NaveggSdkIOS"

s.version = "1.0.0"
 
s.summary = "Library used in the tracker users."
 
s.description = "Library to tracker, custom, segments and onBoarding"
 
s.homepage = 'https://github.com/Navegg/navegg-ios'
s.license = { :type => 'Apache', :file => 'LICENSE' }
s.author = { "Navegg" => "it@navegg.com" }
s.source = { :git => 'https://github.com/Navegg/navegg-ios.git', :tag => s.version.to_s }

s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
s.swift_version = '4.0'
s.ios.deployment_target  = '8.0'
 
s.social_media_url = ''
 
s.ios.source_files = 'Pod/Classes/**/*.{h,m}'

#s.vendored_frameworks = 'Frameworks/Alamofire.framework', 'Frameworks/Reachability.framework', 'Frameworks/SwiftProtobuf.framework'

s.dependency 'Alamofire', '~> 4.5'
s.dependency 'SwiftProtobuf', '~> 1.0'
s.dependency 'ReachabilitySwift'
end
