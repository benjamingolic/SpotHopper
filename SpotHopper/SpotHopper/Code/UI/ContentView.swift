//
//  ContentView.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 08.05.24.
//

import SwiftUI
import SFSafeSymbols

struct ContentView: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var selectedTab: Int = 0
  
  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationStack { Home(onMapTap: {
        selectedTab = 1  // Change to the "Map" tab
      }) }
      .tabItem { Label("Home", systemSymbol: .house) }
      .tag(0)
      
      NavigationStack { MapView() }
        .tabItem { Label("Map", systemSymbol: .map) }
        .tag(1)
      
      NavigationStack { SettingsView() }
        .tabItem { Label("Settings", systemSymbol: .gear) }
        .tag(2)
    }
  }
}
