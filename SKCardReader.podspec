Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '13.0'
s.name = "SKCardReader"
s.summary = "A tool for scanning your credit/debit cards in swift"
s.requires_arc = true

# 2
s.version = "0.0.1"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Syed Kashan" => "syedkashancs305@gmail.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/SyedKashan/SKCardReader"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/SyedKashan/SKCardReader.git", 
             :tag => "#{s.version}" }

# 7
s.framework = "AVFoundation"
s.framework = "Foundation"
s.framework = "Vision"
s.framework = "UIKit"

# 8
s.source_files = "SKCardReader/**/*.{h,m,swift}"

# 9
s.swift_version = "5.0"

end