Pod::Spec.new do |s|
  s.name         = "MBPickerView"
  s.version      = "0.0.2"
  s.summary      = "MBPickerView help you to creat Horizontal Picker View similar ot UIPcikerView"
  s.homepage     = "https://github.com/swifty-iOS/MBPickerView"
  s.license      = "MIT"
  s.author       = { "Swifty-iOS" => "manishej004@gmail.com" }
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/swifty-iOS/MBPickerView.git", :tag =>s.version }
  s.source_files  = "Source/*.swift"
end