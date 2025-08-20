#
# Be sure to run `pod lib lint KeyboardUIBaseLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KeyboardUIBaseLib'
  s.version          = '0.1.0'
  s.summary          = 'A short description of KeyboardUIBaseLib.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'github.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '11423829' => 'tranquthien@gmail.com' }
  s.source           = { :git => 'github.com', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '17.0'

  s.source_files = 'Sources/KeyboardUIBaseLib/**/*.swift'

  s.resource_bundles = {
    'KeyboardUIBaseLibAssets' => ['Sources/KeyboardUIBaseLib/Resources/**/*']
  }

  s.frameworks = 'SwiftUI', 'Foundation'
  s.swift_version = '5.0'
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end

