Pod::Spec.new do |s|

  s.name         = "MSSocialKit"
  s.version      = "0.0.2"
  s.license      = 'MIT'
  s.platform     = :ios, '6.0'

  s.summary      = "A set of view controllers for viewing different social networks."
  s.homepage     = "http://monospacecollective.com"
  s.author       = { "Devon Tivona" => "devon@monospacecollective.com" }
  s.source       = { :git => 'https://github.com/monospacecollective/MSSocialKit.git', :tag => s.version.to_s }
  
  s.source_files = 'MSSocialKit/*.{h,m}'
  s.resources = 'MSSocialKit/*.{png,xcdatamodeld}'

  s.requires_arc = true

  s.frameworks   = ['QuartzCore', 'Social']

  s.dependency 'RestKit', '0.20.0rc1'
  s.dependency 'FXLabel', '~> 1.4.2'
  s.dependency 'KGNoise', '~> 1.1.0'
  s.dependency 'FormatterKit', '~> 1.1.1'
  s.dependency 'SVSegmentedControl', '~> 0.1'
  s.dependency 'UIColor-Utilities', '~> 1.0.1'

end
