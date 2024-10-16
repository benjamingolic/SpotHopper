//
//  SpotHopperApp.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 08.05.24.
//

import SwiftUI
import FirebaseCore

// Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    return true
  }
}

// change
@main
struct SpotHopperApp: App {
  @AppStorage("selectedTheme") var selectedTheme: String = "System"
  @StateObject var appState = AppState()
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // Firebase
  //@StateObject var authViewModel = AuthViewModel()
  
  var body: some Scene {
    WindowGroup {
      SplashScreen()
        .environmentObject(AuthViewModel.shared)
        .environmentObject(appState)
        .preferredColorScheme(colorScheme(for: selectedTheme))
    }
  }
  
  private func colorScheme(for theme: String) -> ColorScheme? {
    switch theme {
    case "Dark": return .dark
    case "Light": return .light
    case "System": return nil
    default: return nil
    }
  }
}
