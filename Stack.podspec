Pod::Spec.new do |s|
    s.name             = "Stack"
    s.version          = "0.1"
    s.summary          = "UIStackView port for iOS 8+"

    s.homepage         = "https://github.com/kean/Stack"
    s.license          = "MIT"
    s.author           = "Alexander Grebenyuk"
    s.social_media_url = "https://twitter.com/a_grebenyuk"
    s.source           = { :git => "https://github.com/kean/Stack.git", :tag => s.version.to_s }

    s.ios.deployment_target = "8.0"
    s.source_files  = "Sources/**/*"
end
