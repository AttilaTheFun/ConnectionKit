
Pod::Spec.new do |s|
  s.name             = 'ConnectionKit'
  s.version          = '0.1.0'
  s.summary          = 'Manages a connection implementing the Relay Cursor Connections Specification'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/logan.shire@gmail.com/ConnectionKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'logan.shire@gmail.com' => 'logan.shire@gmail.com' }
  s.source           = { :git => 'https://github.com/logan.shire@gmail.com/ConnectionKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'ConnectionKit/Source/**/*'

  # s.frameworks = 'UIKit', 'MapKit'

  s.swift_version = '5.0'
  s.dependency 'RxCocoa'
  s.dependency 'RxSwift'
end
