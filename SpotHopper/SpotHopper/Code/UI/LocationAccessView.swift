//
//  LocationAccessView.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 18.09.24.
//

import SwiftUI

struct LocationAccessView: View {
  var onNext: () -> Void
  @EnvironmentObject private var authModel: AuthViewModel
  
  var body: some View {
    VStack {
      Lottie(lottieFile: "Location.json")
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(.cecece)
        .ignoresSafeArea()
      
      VStack(spacing: 12) {
        Text("Enable Location Access")
          .font(.title.bold())
        
        Text("SpotHopper needs continuous access to your location to recommend nearby venues and provide directions.")
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      } .padding(.horizontal)
      
      Spacer()
      
      Button(action: {
        onNext()
        print("Enable Location")
      }) {
        HStack {
          Text("Enable Location")
          Image(systemName: "location.circle")
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
