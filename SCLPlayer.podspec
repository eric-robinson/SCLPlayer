Pod::Spec.new do |s|
  s.name             = "SCLPlayer"
  s.version          = "0.1.0"
  s.summary          = "A component for displaying Soundcloud tracks and playlists in your iOS app."
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
