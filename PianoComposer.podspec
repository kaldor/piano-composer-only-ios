Pod::Spec.new do |s|
  s.name         = 'PianoComposer'
  s.version      = '2.6.1'
  s.swift_version = '5.7'
  s.summary      = 'Enables iOS apps to use mobile composer by Piano.io'
  s.homepage     = 'https://gitlab.com/piano-public/sdk/ios/package'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios, :tvos
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.source       = { :git => 'https://gitlab.com/piano-public/sdk/ios/package.git', :tag => "#{s.version}" }
  s.source_files = 'Composer/Sources/**/*.swift', 'Composer/Sources/**/*.h'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.dependency 'PianoCommon', "~> #{s.version}"
end
