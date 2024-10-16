//
//  OnboardingNavigationView.swift
//  SplinePlayground
//
//  Created by Benjamin Golic on 18.09.24.
//

import SwiftUI

struct OnboardingNavigationView: View {
  @State private var currentScreen = 0
  @State private var onboardingComplete = false
  @State private var email = ""
  @State private var password = ""
  
  var body: some View {
    if onboardingComplete {
      ContentView()
    } else {
      VStack {
        ZStack {
          if currentScreen == 0 {
            WelcomeScreen(onNext: {
              currentScreen += 1
            })
          }
          
          if currentScreen == 1 {
            CreateAccountView(onNext: {
              currentScreen += 1
            }, email: $email, password: $password)
          }
          
          if currentScreen == 2 {
            LocationAccessView(onNext: {
              currentScreen += 1
            })
          }
          
          if currentScreen == 3 {
            ExploreView(onComplete: {
              onboardingComplete = true
            }, email: $email, password: $password)
          }
        }
        .animation(.easeInOut, value: currentScreen)
      }
      .ignoresSafeArea(edges: .top)
    }
  }
}
