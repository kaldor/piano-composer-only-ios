Pod::Spec.new do |s|
  s.name         = 'PianoCommon'
  s.version      = '2.5.0'
  s.swift_version = '5.5'
  s.summary      = 'Common iOS components by Piano.io'
  s.homepage     = 'https://gitlab.com/piano-public/sdk/ios/package'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios, :tvos
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.source       = { :git => 'https://gitlab.com/piano-public/sdk/ios/package.git', :tag => "#{s.version}" }
  s.resource_bundle = {
      "PianoSDK_PianoCommon" => ["Common/Sources/Resources/*"]
  }
  s.source_files = 'Common/Sources/*.swift', 'Common/Sources/**/*.h'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
