//
//  Home.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 08.05.24.
//

import SwiftUI

struct FavView: View {
  @State private var searchText = ""
  @State private var showingLocationOptions = false
  @State private var showingFilters = false
  
  @State private var selectedLocation = "Current Location"
  @State private var locations = ["Current Location", "Linz", "Vienna", "Wels", "Pasching"]
  
  @State private var selectedFilter = "None"
  @State private var filters = ["None", "Restaurant", "Cafe", "Club", "Hookah Bar"]
  
  
  var body: some View {
    VStack {
      Text("Depricated Favourites")
      /*
      ScrollView {
        LazyVStack {
          ForEach(filteredLocals) { local in
            LocalCard(
              imageName: local.imageName,
              localName: local.localName,
              openingHours: local.openingHours,
              address: local.address
            )
          }
        }
      }
      */
    }
    .background(Color("bgColors").ignoresSafeArea())
  }
}

#Preview {
  FavView()
}
