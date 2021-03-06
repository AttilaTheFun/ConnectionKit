
Pod::Spec.new do |s|
  s.name             = 'ConnectionKit'
  s.version          = '0.7.0'
  s.summary          = 'Manages a connection implementing the Relay Cursor Connections Specification'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library provides utilities for managing a connection implementing the Relay Cursor Connections Specification.

It also provides reactive (RxSwift) bindings for observing that connection's states.
                       DESC

  s.homepage         = 'https://github.com/AttilaTheFun/ConnectionKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'logan.shire@gmail.com' => 'logan.shire@gmail.com' }
  s.source           = { :git => 'https://github.com/AttilaTheFun/ConnectionKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.static_framework = true

  s.source_files = 'Source/**/*'
  s.dependency 'RxCocoa'
  s.dependency 'RxSwift'
end
