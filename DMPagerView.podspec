Pod::Spec.new do |s|
  s.name             = "DMPagerView"
  s.version          = "1.0.0"
  s.summary          = "Pager view with reusable page and storyboard support."
  s.description      = <<-DESC
                        DMPagerView is a swift conversion of https://github.com/maxep/MXPagerView
                       DESC

  s.homepage         = "https://github.com/dominicmdev/DMPagerView"
  s.license          = 'MIT'
  s.authors          = { "Dominic Miller" => "dominicmdev@gmail.com", "Maxime Epain" => "maxime.epain@gmail.com" }
  s.source           = { :git => "https://github.com/dominicmdev/DMPagerView.git", :tag => s.version.to_s }

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.source_files = 'DMPagerView/*.swift'

end
