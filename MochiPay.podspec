#
# Be sure to run `pod lib lint MochiPay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'MochiPay'
  s.version               = '0.1.0'
  s.homepage              = 'https://github.com/PKLOT/mochipay-framework-ios.git'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Wii Lin' => 'wiilin@pklotcorp.com' }
  s.ios.deployment_target = '11.0'
  s.swift_version         = '4.0'
  s.requires_arc          = true
  s.source                = { :git => 'https://github.com/PKLOT/mochipay-framework-ios.git', :tag => '0.1.0' }
  s.source_files          = 'MochiPay/Classes/**/*'
  

  s.description           = 'Mochi Pay Support for ApplePay.'
  s.summary               = 'MochiPay Support for ApplePay.'

  
  # s.resource_bundles = {
  #   'MochiPay' => ['MochiPay/Assets/*.png']
  # }
  # s.ios.exclude_files = 'MochiPay/Classes/MPPaymentAuthorizationControllerDelegate.swift'

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'PassKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
