//
//  FontPreview.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 08.05.24.
//

import SwiftUI

struct FontPreview: View {
  var body: some View {
    ZStack {
      Color(.bgColors)
        .ignoresSafeArea(.all)
      VStack {
        Text("SpotHopper! Thin Italic")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.thin)
          .italic()
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Thin")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.thin)
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Regular")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.regular)
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Medium")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.medium)
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Medium Italic")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.medium)
          .italic()
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Light")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.light)
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Light Italic")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.light)
          .italic()
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Italic")
          .font(.custom("Supreme", size: 24))
          .italic()
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Extralight")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.thin)
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Extralight Italic")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.ultraLight)
          .italic()
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Extrabold Italic")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.heavy)
          .italic()
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Extrabold")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.heavy)
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Bold Italic")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.semibold)
          .italic()
          .foregroundStyle(.rbPurple)
        
        Text("SpotHopper! Bold")
          .font(.custom("Supreme", size: 24))
          .fontWeight(.semibold)
          .foregroundStyle(.rbPurple)
      }
      .padding()
    }
  }
}

#Preview {
  FontPreview()
}
