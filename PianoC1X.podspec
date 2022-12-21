Pod::Spec.new do |s|
  s.name         = 'PianoC1X'
  s.version      = '2.6.2'
  s.swift_version = '5.7'
  s.summary      = 'Enables iOS apps to use C1X integration by Piano.io'
  s.homepage     = 'https://gitlab.com/piano-public/sdk/ios/package'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios
  s.ios.deployment_target = '12.0'
  s.source       = { :git => 'https://gitlab.com/piano-public/sdk/ios/package.git', :tag => "#{s.version}" }
  s.source_files = 'C1X/Sources/**/*.swift', 'C1X/Sources/**/*.h'
  s.static_framework = true
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.dependency 'PianoComposer', "~> #{s.version}"
  s.dependency 'PianoTemplate', "~> #{s.version}"
  s.dependency 'CxenseSDK', '~> 1.9.11'
end
