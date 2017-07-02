Pod::Spec.new do |spec|
  spec.name         = 'Rainbows'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MPL-2.0', :file => 'LICENSE' }
  spec.homepage     = 'https://github.com/regexident/Rainbows'
  spec.authors      = 'Vincent Esche'
  spec.summary      = 'A Metal-backed, blazingly fast alternative to CAGradientLayer.'
  spec.source       = { :git => 'https://github.com/regexident/Rainbows.git', :tag => '1.0.0' }
  spec.source_files = 'Rainbows/*.{swift,metal}'
  spec.framework    = 'Metal', 'CoreGraphics', 'QuartzCore'
  spec.ios.deployment_target  = '10.0'
end