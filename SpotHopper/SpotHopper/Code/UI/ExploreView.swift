//
//  ExploreView.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 18.09.24.
//

import SwiftUI

struct ExploreView: View {
  var onComplete: () -> Void
  @EnvironmentObject private var authModel: AuthViewModel
  @Binding var email: String
  @Binding var password: String
  
  var body: some View {
    VStack {
      Lottie(lottieFile: "Explore.json")
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(.cecece)
        .ignoresSafeArea()
      
      VStack(spacing: 12) {
        Text("You're Ready to Go!")
          .font(.title.bold())
        
        Text("Start exploring and hopping from one amazing spot to the next.")
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      } .padding(.horizontal)
      
      Spacer()
      
      Button(action: {
        authModel.completeOnboarding() // user finished onboarding
        authModel.SignUp(emailAdress: email, password: password)
        print("Let's Go!")
      }) {
        HStack {
          Text("Let's Go")
          Image(systemName: "arrow.right.circle")
        }
      }
      .padding(15)
      .background(Color.rbPurple)
      .foregroundColor(.white)
      .cornerRadius(10)
      
      Spacer()
    }
  }
}
