Pod::Spec.new do |s|

  s.name         = "MMAccessoryPanel"
  s.version      = "1.0.0"
  s.summary      = "Creates and manages collapsible bars on top of any UIScrollView, just below the navigation bar."

  s.description  = <<-DESC
                   MMAccessoryPanel creates and manages collapsible bars on top of any 
                   UIScrollView, just below the navigation bar. MMAccessoryPanel collapses 
                   to invisible when user scroll down, and expand when when user scroll up. 
                   
                   MMAccessoryPanel helps maximize usable screen estate for scroll view. 
                   The behavior is some what similar to the top bar in Facebook app.
                   DESC

  s.homepage     = "http://www.medallia.com"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = "Minh Tran"
  s.social_media_url   = "http://twitter.com/zealix"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/medallia/ios-MMAccessoryPanel.git", :tag => "v1.0.0" }
  s.source_files  = "MMAccessoryPanel", "MMAccessoryPanel/**/*.{h,m}"
  s.public_header_files = "MMAccessoryPanel/**/*.h"
  s.requires_arc = true

end
