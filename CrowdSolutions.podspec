#
# Be sure to run `pod lib lint CrowdSolutions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name            = 'CrowdSolutions'
  s.version         = '0.1.1'
  s.summary         = 'AppCats CrowdSOLUTIONS SDK.'
  s.description     = 'AppCats CrowdSOLUTIONS SDK for iOS'

  s.homepage        = 'http://appcats.com'
  s.license         = { :type => 'MIT', :file => 'LICENSE' }
  s.author          = 'AppCats, LLC'
  s.source          = { :git => "https://github.com/AppCats/crowd_solutions_ios.git", :tag => "#{s.version}" }

  s.platform        = :ios, '15.0'
  s.ios.deployment_target = '15.0'

  s.source_files = 'Sources/**/*.{swift,h,m}'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.8' }
  s.swift_version       = '5.8'

  # Required Frameworks
  s.ios.framework       = [ 'Foundation', 'Combine' ]
end
