Pod::Spec.new do |spec|
  spec.name = "instrumentisto-libwebrtc-bin"
  spec.version = "134.0.6998.88"
  spec.summary = "Pre-compiled `libwebrtc` library for Darwin used by Medea Flutter-WebRTC."

  spec.homepage = "https://github.com/instrumentisto/libwebrtc-bin"
  spec.license = { :type => 'BSD', :file => 'WebRTC.xcframework/LICENSE.md' }
  spec.author = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
  spec.ios.deployment_target = '10.0'

  spec.source = { :http => "https://github.com/instrumentisto/libwebrtc-bin/releases/download/134.0.6998.88/libwebrtc-ios.zip" }
  spec.vendored_frameworks = "WebRTC.xcframework"

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
end
