Pod::Spec.new do |s|
  s.name         = "MSSocialKit"
  s.version      = "0.0.1"
  s.license      = 'MIT'
  s.platform     = :ios, '6.0'

  s.summary      = "A set of view controllers for viewing different social networks."
  s.homepage     = "http://monospacecollective.com"
  s.author       = { "Devon Tivona" => "devon@monospacecollective.com" }
  s.source       = { :git => 'https://github.com/monospacecollective/MSSocialKit.git', :tag => s.version.to_s }
  
  s.source_files = 'MSSocialKit/*.{h,m}'

  s.requires_arc = true

  s.frameworks   = 'QuartzCore'

  s.dependency 'UIColor-Utilities'    , '~> 1.0.1'
  s.dependency 'KGNoise'              , '~> 1.1.0'
end
