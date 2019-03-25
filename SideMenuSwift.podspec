Pod::Spec.new do |s|

    s.name         = "SideMenuSwift"
    s.version      = "1.0.2"
    s.summary      = "An interactive iOS side menu with rich features."
  
    s.description  = <<-DESC
    SideMenuSwift is an iOS container view controller written in Swift. Its easy-to-use and supports both storyboard and code. It provides several ways to reveal the menu and animate the status bar.
                     DESC
  
    s.homepage     = "https://github.com/kukushi/SideMenu"
    s.license      = "MIT"
    s.author       = { "kukushi" => "" }
    s.platform     = :ios, "9.0"
    s.source       = { :git => "https://github.com/kukushi/SideMenu.git", :tag => s.version }
    s.source_files  = "SideMenu/*.{h,m,swift}"
    s.swift_version = "4.2"
    s.requires_arc = true
  
  end
  