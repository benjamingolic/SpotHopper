//
//  SplashScreen.swift
//  SplinePlayground
//
//  Created by Benjamin Golic on 19.09.24.
//

import SwiftUI

struct SplashScreen: View {
  @State private var showSplash = true // Controls showing the splash screen
  @State private var size: CGFloat = 0.8
  @State private var purpleOpacity = 0.5
  
  @EnvironmentObject private var authModel: AuthViewModel
  @EnvironmentObject var appState: AppState
  
  // Check if onboarding has been shown
  var hasSeenOnboarding: Bool {
    UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
  }
  
  var body: some View {
    if showSplash {
      // Splash screen content
      ZStack {
        LinearGradient(gradient: Gradient(colors: [Color(.rbPurple), Color(.systemIndigo)]),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
        .ignoresSafeArea()
        .opacity(purpleOpacity)
        .blur(radius: 10)
        .onAppear {
          withAnimation(.easeInOut(duration: 1.5)) {
            self.purpleOpacity = 0.0
          }
        }
        
        VStack {
          Spacer()
          
          Image("spothopper")
            .resizable()
            .scaledToFit()
            .frame(width: 180, height: 180)
            .scaleEffect(size)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
            .onAppear {
              withAnimation(.spring(response: 1.2, dampingFraction: 0.6, blendDuration: 0)) {
                self.size = 1.0
              }
            }
          
          Spacer()
        }
      }
      .onAppear {
        authModel.listenToAuthState() // Start listening to the auth state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
          self.showSplash = false // Dismiss the splash screen after the animation
        }
      }
    } else {
      // Show Onboarding or Content based on user state
      if authModel.user == nil || !authModel.hasCompletedOnboarding {
        OnboardingNavigationView()
          .onDisappear {
            authModel.hasCompletedOnboarding = true // Mark onboarding as completed when it disappears
          }
      } else {
        ContentView()
      }
      
      //prep for onboard for just installed users:
      /*
       
       // Show Onboarding, CreateAccountView, or ContentView based on user state
       if authModel.user == nil {
       // User is not logged in
       if hasSeenOnboarding {
       CreateAccountView(onNext: { /* Add your navigation logic here */ })
       } else {
       OnboardingNavigationView()
       .onDisappear {
       // Mark onboarding as completed and save it in UserDefaults
       UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
       }
       }
       } else if !authModel.hasCompletedOnboarding {
       // Logged in, but not completed onboarding
       OnboardingNavigationView()
       .onDisappear {
       authModel.hasCompletedOnboarding = true
       }
       } else {
       // User logged in and completed onboarding
       ContentView()
       }
       */
    }
  }
}
