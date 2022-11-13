Pod::Spec.new do |s|
  s.name         = 'PianoOAuth'
  s.version      = '2.6.0'
  s.swift_version = '5.5'
  s.summary      = 'Enables iOS apps to sign in with Piano.io'
  s.homepage     = 'https://gitlab.com/piano-public/sdk/ios/package'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios
  s.ios.deployment_target = '12.0'
  s.source       = { :git => 'https://gitlab.com/piano-public/sdk/ios/package.git', :tag => "#{s.version}" }
  s.resource_bundle = {
      "PianoSDK_PianoOAuth" => ["OAuth/Sources/Resources/*"]
  }
  s.source_files = 'OAuth/Sources/*.swift', 'OAuth/Sources/**/*.h'
  s.static_framework = true
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.dependency 'PianoCommon', "~> #{s.version}"
  s.dependency 'GoogleSignIn', '~> 6.2.4'
  s.dependency 'FBSDKLoginKit', '~> 15.1.0'
end
