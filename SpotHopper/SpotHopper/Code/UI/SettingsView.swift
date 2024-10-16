//
//  SettingsView.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 08.05.24.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.openURL) var openURL
  @AppStorage("vibrationsEnabled") var vibrationsEnabled: Bool = true
  
  @EnvironmentObject private var authModel: AuthViewModel
  @AppStorage("selectedTheme") var selectedTheme: String = "System"
  let themes = ["Dark", "Light", "System"]
  
  var body: some View {
    Form {
      Section(header: Text("User Information")) {
        if let user = authModel.user {
          Text("Logged in as: \(user.email ?? "Unknown User")")
          
          //            Text("Hello, \(authModel.firstName) \(authModel.lastName)")
          //              .font(.title2)
          //              .fontWeight(.bold)
        } else {
          Text("Not logged in")
        }
      }
      
      
      Section(header: Text("SpotHopper")) {
        Text("SpotHopper is an App that recommends you cool new Spots near you to check out!")
      }
      
      Section(header: Text("SpotHopper")) {
        Button(action: {
          let subject = "SpotHopper: User Problem Report"
          let email = SupportEmail(subject: subject)
          email.send(openURL: openURL)
        }) {
          HStack{
            Image(systemName: "exclamationmark.bubble")
            Text("Report a Problem")
          }
        }
        Button(action: {
          let subject = "SpotHopper: User Feedback/Ideas"
          let email = SupportEmail(subject: subject)
          email.send(openURL: openURL)
        }) {
          HStack{
            Image(systemName: "ellipsis.message")
            Text("Feedback or Ideas?")
          }
        }
      }
      
      Section(header: Text("General")) {
        HStack{
          HStack {
            Image(systemName: symbolName(for: selectedTheme))
            Picker("Appearance", selection: $selectedTheme) {
              ForEach(themes, id: \.self) {
                Text($0)
              }
            }.pickerStyle(.menu)
          }
        }
        HStack{
          Image(systemName: "waveform")
          Toggle(isOn: $vibrationsEnabled) {
            Text("Vibrations")
          }
        }
      }
      
      Section(header: Text("Version")) {
        HStack{
          Image(systemName: "chevron.left.slash.chevron.right")
          Text("Version: \(getAppVersion())")
        }
        Button(action: openAppSettings) {
          HStack {
            Image(systemName: "gear")
            Text("More Settings")
          }
          
        }
      }.foregroundStyle(.gray)
      
      Button {
        authModel.signOut()
      } label: {
        Text("Logout")
      }
      .foregroundStyle(.red)
    }
    .background(Color(colorScheme == .dark ? Color(red: 18/255, green: 18/255, blue: 18/255) : Color(red: 245/255, green: 245/255, blue: 245/255)))
    .scrollContentBackground(.hidden)
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.large)
    .foregroundStyle(.txt)
    
  }
  
  func getAppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
  }
  
  func openAppSettings() {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
          UIApplication.shared.canOpenURL(settingsUrl) else {
      return
    }
    
    UIApplication.shared.open(settingsUrl)
  }
  
  func colorScheme(for theme: String) -> ColorScheme? {
    switch theme {
    case "Dark": return .dark
    case "Light": return .light
    case "System": return nil
    default: return nil
    }
  }
  
  func symbolName(for theme: String) -> String {
    switch theme {
    case "Dark": return "moon"
    case "Light": return "sun.max"
    case "System": return "circle.lefthalf.filled.inverse"
    default: return "circle.lefthalf.filled.inverse"
    }
  }
}

struct SupportEmail {
  let toAddress: String = "benjamin@golic.at"
  let subject: String
  var body: String { """
    Application Name: \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown")
    iOS Version: \(UIDevice.current.systemVersion)
    Device Model: \(UIDevice.current.model)
    App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version")
    App Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown App Build Version")
    
    Please describe your issue below
    ------------------------------------
  
  """}
  
  func send(openURL: OpenURLAction) {
    let replacedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    let replacedBody = body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    let urlString = "mailto:\(toAddress)?subject=\(replacedSubject)&body=\(replacedBody)"
    guard let url = URL(string: urlString) else { return }
    openURL(url) { accepted in
      if !accepted {
        print("Device doesn't support email.\n \(body)")
      }
    }
  }
}


#Preview {
  SettingsView()
}
