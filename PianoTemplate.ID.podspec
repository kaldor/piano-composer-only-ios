Pod::Spec.new do |s|
  s.name         = 'PianoTemplate.ID'
  s.version      = '2.5.4'
  s.swift_version = '5.5'
  s.summary      = 'Enables iOS apps to use ID templates by Piano.io'
  s.homepage     = 'https://gitlab.com/piano-public/sdk/ios/package'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios
  s.ios.deployment_target = '10.0'
  s.source       = { :git => 'https://gitlab.com/piano-public/sdk/ios/package.git', :tag => "#{s.version}" }
  s.source_files = 'Template/ID/Sources/**/*.swift', 'Template/ID/Sources/**/*.h'
  s.static_framework = true
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.dependency 'PianoTemplate', "~> #{s.version}"
  s.dependency 'PianoOAuth', "~> #{s.version}"
end
