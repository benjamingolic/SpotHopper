//
//  MapView.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 17.09.24.
//

import SwiftUI
import MapKit

struct MapView: View {
  @StateObject private var locationViewModel = LocationViewModel()  // View model for tracking location
  @EnvironmentObject var appState: AppState// Access AppState environment
  @State private var position: MapCameraPosition = .automatic  // Map camera position
  @State private var region = MKCoordinateRegion()  // Region to manage the map view
  @State private var radiusInKilometers: Double = 10.0  // Radius in kilometers
  @State private var showAppleMapsButton = true  // Show the button to open Apple Maps
  @State private var userRadiusOverlay: MKCircle?  // Circle overlay for the radius
  @State private var hasSetCameraPosition = false  // New state to track if the camera has been set once
  
  @EnvironmentObject var authModel: AuthViewModel
  
  var body: some View {
    VStack {
      Map(position: $position) {
        // Always show the user's location on the map
        UserAnnotation()
        
        // Show fixed radius around the user using a transparent fill and solid stroke
        if let userRadiusOverlay = userRadiusOverlay {
          MapCircle(center: userRadiusOverlay.coordinate, radius: userRadiusOverlay.radius)
            .stroke(Color.rbPurple, lineWidth: 2)
            .foregroundStyle(.rbPurple.opacity(0.3))
        }
        
        // If there is a venue selected, draw a marker and show Apple Maps button
        if let selectedLocation = authModel.selectedLocation {
          Marker("\(selectedLocation.name)", coordinate: selectedLocation.coordinate).tint(.rbPurple)
        }
        
        // Draw route between user and selected spot if available
        if let polyline = authModel.selectedLocation?.routePolyline {
          MapPolyline(polyline)
            .stroke(Color.blue, lineWidth: 3)
        }
      }
      .mapStyle(.standard(elevation: .realistic))
      .mapControls {
        MapUserLocationButton()
        MapPitchToggle()
        MapCompass()
        MapScaleView()
      }
      .onAppear {
        // Only set the camera position once when the map appears
        if let userLocation = locationViewModel.userLocation, !hasSetCameraPosition {
          region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
          )
          position = .region(region)
          
          // Create a circle overlay with a fixed radius (in meters)
          let radiusInMeters: CLLocationDistance = (authModel.selectedRadius ?? 3) * 1000.0
          userRadiusOverlay = MKCircle(center: userLocation.coordinate, radius: radiusInMeters)
          
          hasSetCameraPosition = true  // Mark that the camera has been set
        }
      }
      .onChange(of: locationViewModel.userLocation) { _, newLocation in
        if let userLocation = newLocation {
          // Only update the radius and user annotation, without changing the camera position
          print("Radius for MapView: \(authModel.selectedRadius)")
          let radiusInMeters: CLLocationDistance = (authModel.selectedRadius ?? radiusInKilometers) * 1000.0
          userRadiusOverlay = MKCircle(center: userLocation.coordinate, radius: radiusInMeters)
        }
      }
      .onChange(of: authModel.selectedLocation) { _, newSpot in
        if newSpot == nil {
          showAppleMapsButton = false
        }
      }
      .overlay(alignment: .bottom, content: {
        if showAppleMapsButton, let selectedLocation = authModel.selectedLocation {
          VStack(spacing: -10) {
            VStack {
              Text("Driving: \(authModel.selectedLocation?.travelTime.driving ?? "N/A")")
              
              Text("Walking: \(authModel.selectedLocation?.travelTime.walking ?? "N/A")")
            }.padding()
              .font(.subheadline)
              .foregroundStyle(.txt)
              .background(.ultraThinMaterial.opacity(0.8))
              .cornerRadius(15)
            
            Button(action: {
              openInAppleMaps(destination: selectedLocation.coordinate)
            }) {
              Text("Open in Apple Maps")
                .foregroundColor(.white)
                .padding()
                .background(Color.rbPurple)
                .cornerRadius(15)
            }
            .padding()
          }
        }
      })
    }
  }
  
  // Function to open directions in Apple Maps
  private func openInAppleMaps(destination: CLLocationCoordinate2D) {
    let userLocation = MKMapItem.forCurrentLocation()
    let destinationPlacemark = MKPlacemark(coordinate: destination)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
    destinationMapItem.name = "Destination"
    
    MKMapItem.openMaps(
      with: [userLocation, destinationMapItem],
      launchOptions: [
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
      ]
    )
  }
}


#Preview {
  MapView()
}

