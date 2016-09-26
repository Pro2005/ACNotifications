Pod::Spec.new do |s|

  s.name         = "ACNotifications"
  s.version      = "0.0.1"
  s.summary      = "Highly customisable but very simple iOS notifications."
  s.description  = <<-DESC
ACNotifications allows you to easily show any UIViews (images, controls, complex composite views, Nib-driven views, etc.) as notifications with different animations and positions. Provides a lot of default notifications and animations.
                   DESC
  s.homepage     = "https://github.com/Avtolic/ACNotifications"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Avtolic"
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/Avtolic/ACNotifications.git", :tag => "#{s.version}" }
  s.source_files  = "ACNotifications/*.swift"
  s.framework  = "UIKit"

end
