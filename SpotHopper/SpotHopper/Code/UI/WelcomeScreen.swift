//
//  ContentView.swift
//  SplinePlayground
//
//  Created by Benjamin Golic on 18.09.24.
//

import SplineRuntime
import SwiftUI

struct WelcomeScreen: View {
  var onNext: () -> Void
  var body: some View {
    VStack {
      Onboard3DView()
        .frame(height: 500)
        .ignoresSafeArea()
      
      VStack(spacing: 12) {
        Text("SpotHopper")
          .font(.title.bold())
        
        Text("Welcome to SpotHopper! Discover your next favourite spot, every day.")
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      } .padding(.horizontal)
      
      
      Spacer()
      
      Button(action: {
        onNext()
        print("Get Started!")
      }) {
        HStack {
          Text("Get Started")
          Image(systemName: "chevron.right.circle")
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

struct Onboard3DView: View {
  var body: some View {
    // fetching from cloud
    let url = URL(string: "https://build.spline.design/FSi32ajsExXBbB8Y3-gb/scene.splineswift")!
    
    // fetching from local
    // let url = Bundle.main.url(forResource: "scene", withExtension: "splineswift")!
    
    SplineView(sceneFileURL: url)
  }
}
