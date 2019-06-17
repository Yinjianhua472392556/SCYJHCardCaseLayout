Pod::Spec.new do |s|
    s.name         = "SCYJHCardCaseLayout"
    s.version      = "1.0.1"
    s.ios.deployment_target = '8.0'
    s.summary      = "A delightful setting interface framework."
    s.homepage     = "https://github.com/Yinjianhua472392556/SCYJHCardCaseLayout"
    s.license              = { :type => "MIT", :file => "LICENSE" }
  s.author           = { 'Yinjianhua472392556' => '18620526218@163.com' }
    s.social_media_url   = "http://weibo.com/u/5348162268"
    s.source       = { :git => 'https://github.com/Yinjianhua472392556/SCYJHCardCaseLayout.git', :tag => s.version.to_s}
    s.source_files  = "SCYJHCardCaseLayout/*.{h,m}"
    s.requires_arc = true
end