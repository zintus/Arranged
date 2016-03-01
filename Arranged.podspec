Pod::Spec.new do |s|
    s.name             = "Arranged"
    s.version          = "0.1"
    s.summary          = "UIStackView port for iOS 8+"

    s.homepage         = "https://github.com/kean/Arranged"
    s.license          = "MIT"
    s.author           = "Alexander Grebenyuk"
    s.social_media_url = "https://twitter.com/a_grebenyuk"
    s.source           = { :git => "https://github.com/kean/Arranged.git", :tag => s.version.to_s }

    s.dependency 'PureLayout', '~> 3.0'

    s.ios.deployment_target = "8.0"
    s.source_files  = "Sources/**/*"
end
