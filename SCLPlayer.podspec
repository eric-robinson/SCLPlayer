Pod::Spec.new do |s|
  s.name             = "SCLPlayer"
  s.version          = "0.2.2"
  s.summary          = "A SoundCloud player for iOS apps. Uses UIWebView to display their HTML5 widget."
  s.homepage         = "https://github.com/eric-robinson/SCLPlayer"
  s.license          = 'MIT'
  s.author           = { "Eric Robinson" => "eric.robinson@me.com" }
  s.source           = { :git => "https://github.com/eric-robinson/SCLPlayer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/eric_robinson'
  s.platform	     = :ios, '7.0'
  s.requires_arc	 = true
  s.source_files 	 = 'Pod/Classes'
  s.resources 		 = 'Pod/Assets/*.{html,png}'
  s.frameworks 		 = 'UIKit'
end
