Pod::Spec.new do |spec|
    spec.name         = "MedeaWebRTC"
    spec.version      = "104.5112.05"
    spec.summary      = "WebRTC pre-compiled library for Darwin used by Instrumentisto Flutter-WebRTC."
    spec.description  = "WebRTC pre-compiled library for Darwin used by Instrumentisto Flutter-WebRTC."
  
    spec.homepage     = "https://github.com/instrumentisto/libwebrtc-bin"
    spec.license      = { :file => 'LICENSE.md' }
    spec.author       = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
    spec.ios.deployment_target = '10.0'
    spec.osx.deployment_target = '10.11'
  
    spec.source       = { :http => "https://github.com/instrumentisto/libwebrtc-bin/releases/download/106.0.5249.119/libwebrtc-ios.tar.gz" }
    spec.vendored_frameworks = "WebRTC.xcframework"
  end
