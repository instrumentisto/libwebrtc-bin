Pod::Spec.new do |spec|
    spec.name         = "MedeaWebRTC"
    spec.version      = "106.0.5249.119"
    spec.summary      = "WebRTC pre-compiled library for Darwin used by Instrumentisto Flutter-WebRTC."
  
    spec.homepage     = "https://github.com/instrumentisto/libwebrtc-bin"
    spec.license      = { :type => 'BSD', :file => 'WebRTC.xcframework/LICENSE' }
    spec.author       = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
    spec.ios.deployment_target = '10.0'
    spec.osx.deployment_target = '10.11'
  
    spec.source       = { :http => "https://github.com/instrumentisto/libwebrtc-bin/releases/download/106.0.5249.119/libwebrtc-ios.zip" }
    spec.vendored_frameworks = "WebRTC.xcframework"
end
