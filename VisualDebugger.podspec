#pod lint VisualDebugger.podspec
#pod trunk push VisualDebugger.podspec

Pod::Spec.new do |s|
  s.name        = "VisualDebugger"
  s.version     = "1.0.1"
  s.summary     = "The most elegant and easiest way to visual you data in playground"
  s.homepage    = "https://github.com/chenyunguiMilook/VisualDebugger"
  s.license     = { :type => "MIT" }
  s.authors     = { "chenyunguiMilook" => "286224043@qq.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.11"
  s.ios.deployment_target = "8.0"
  s.source   = { :git => "https://github.com/chenyunguiMilook/VisualDebugger.git", :tag => s.version }
  s.source_files = "Source/*.swift"
end
