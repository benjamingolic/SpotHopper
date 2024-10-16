//
//  LocationCardView.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 19.09.24.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationCardView: View {
  @State private var address: String = "Loading address..."
  @State private var position: MapCameraPosition = .region(MKCoordinateRegion())
  
  var locationName: String
  var type: String
  var style: String
  var coordinate: CLLocationCoordinate2D
  var onMapTap: () -> Void
  
  var body: some View {
    VStack(alignment: .leading) {
      Map(position: $position, interactionModes: []) {
        Marker("\(locationName)", coordinate: coordinate).tint(.rbPurple)
      }
      .mapStyle(.standard(elevation: .realistic))
      .frame(height: 200)
      .cornerRadius(10)
      .onAppear {
        let region = MKCoordinateRegion(
          center: coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.02)
        )
        position = .region(region)
        reverseGeocodeLocation(coordinate: coordinate)
      }
      .onTapGesture {
        onMapTap()
      }
      
      
      Text(locationName)
        .font(.headline)
        .foregroundStyle(.txt)
        .padding(.top, 10)
      
      Text(address)
        .font(.subheadline)
        .foregroundStyle(.txt.opacity(0.65))
        .padding(.bottom, 5)
      
      HStack {
        Text(type.uppercased())
          .font(.caption)
          .fontWeight(.bold)
          .padding(5)
          .background(Color.gray.opacity(0.2))
          .cornerRadius(5)
        
        Text(style.uppercased())
          .font(.caption)
          .fontWeight(.bold)
          .padding(5)
          .background(Color.gray.opacity(0.2))
          .cornerRadius(5)
        
        Spacer()
      }
    }
    .frame(maxWidth: 300)
    .padding()
    .background(.cardColors)
    .cornerRadius(15)
    .shadow(radius: 5)
  }
  
  private func reverseGeocodeLocation(coordinate: CLLocationCoordinate2D) {
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    let geocoder = CLGeocoder()
    
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        print("Error with reverse geocoding: \(error.localizedDescription)")
        self.address = "Unknown address"
      } else if let placemark = placemarks?.first {
        let houseNumber = placemark.subThoroughfare ?? ""
        let street = placemark.thoroughfare ?? ""
        let postcode = placemark.postalCode ?? ""
        let city = placemark.locality ?? ""
        
        self.address = "\(street) \(houseNumber), \(postcode) \(city)"
      } else {
        self.address = "Address not found"
      }
    }
  }
}

#Preview {
  LocationCardView(
    locationName: "Selectum Garden Lounge",
    type: "Cocktail & Shisha",
    style: "Cozy",
    coordinate: CLLocationCoordinate2D(latitude: 48.2644626356778, longitude: 14.288277344483305),
    onMapTap: {
      print("open MapView here")
    }
  )
}

