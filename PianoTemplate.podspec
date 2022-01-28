Pod::Spec.new do |s|
  s.name         = 'PianoTemplate'
  s.version      = '2.5.0'
  s.swift_version = '5.5'
  s.summary      = 'Enables iOS apps to use templates by Piano.io'
  s.homepage     = 'https://gitlab.com/piano-public/sdk/ios/package'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios
  s.ios.deployment_target = '10.0'
  s.source       = { :git => 'git@gitlab.com:piano-public/sdk/ios/package.git', :tag => "#{s.version}" }
  s.source_files = 'Template/Sources/**/*.swift', 'Template/Sources/**/*.h'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.dependency 'PianoComposer', "~> #{s.version}"
end
