Pod::Spec.new do |s|
  s.name         = 'LUKeychainAccess'
  s.version      = '3.1.0'
  s.summary      = 'A wrapper for iOS Keychain Services that behaves just like NSUserDefaults.'
  s.homepage     = 'https://github.com/TheLevelUp/LUKeychainAccess'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Costa Walcott' => 'costa@thelevelup.com', 'Donald Gaxho' => 'dgaxho@gmail.com', 'Ben Cootner' => 'bcootner@gmail.com' }
  s.source       = { :git => 'https://github.com/TheLevelUp/LUKeychainAccess.git', :tag => "#{s.version}" }
  s.ios.deployment_target = '9.0'
  s.watchos.deployment_target = '4.0'
  s.source_files = 'LUKeychainAccess'
  s.frameworks   = 'Security'
  s.requires_arc = true
end
