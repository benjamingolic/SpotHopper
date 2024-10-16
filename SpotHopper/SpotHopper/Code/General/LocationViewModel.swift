//
//  LocationViewModel.swift
//  SpotHopper
//
//  Created by Teodor Brankovic on 15.09.24.
//

import Foundation
import CoreLocation
import Firebase

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  @Published var locations = [Location]()
  @Published var userLocation: CLLocation? // Continuously store user's live location
  @Published var permissionDenied = false  // For handling location permission denial
  
  private let locationManager = CLLocationManager()
  let db = Firestore.firestore() // database
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    startTrackingUserLocation() // Start tracking user location as soon as the app starts
  }
  
  // Continuously track user location
  func startTrackingUserLocation() {
    locationManager.startUpdatingLocation()  // Continuously update user location
  }
  
  // CLLocationManagerDelegate method called when user location is updated
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      self.userLocation = location  // Store the user's live location
      print("User's location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
  }
  
  // Funktion für permissions handling
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .denied:
      permissionDenied = true  // Handle permission denial
    default:
      break
    }
  }
  
  // GEO QUERY
  func fetchLocations(type: String, radiusInKilometers: Double, completion: @escaping([Location]) -> Void) {
    AuthViewModel.shared.selectedRadius = radiusInKilometers
    
    guard let userLocation = userLocation else {
      print("User location is not available")
      return
    }
    
    let radiusInMeters = radiusInKilometers * 1000 // get meters for filtering
    
    // Calculate bounding box for latitude and longitude based on radius
    let latDelta = radiusInKilometers / 111.32  // 111.32 km per degree of latitude
    let lonDelta = radiusInKilometers / (111.32 * cos(userLocation.coordinate.latitude * Double.pi / 180))
    
    let minLatitude = userLocation.coordinate.latitude - latDelta
    let maxLatitude = userLocation.coordinate.latitude + latDelta
    let minLongitude = userLocation.coordinate.longitude - lonDelta
    let maxLongitude = userLocation.coordinate.longitude + lonDelta
    
    // Debug: Test min-max Latitude & Longitude
    print("Latitude Range: \(minLatitude) to \(maxLatitude)")
    print("Longitude Range: \(minLongitude) to \(maxLongitude)")
    
    let locationsRef = db.collection("locations")
    
    var query = locationsRef
      .whereField("latitude", isGreaterThanOrEqualTo: minLatitude)
      .whereField("latitude", isLessThanOrEqualTo: maxLatitude)
      .whereField("longitude", isGreaterThanOrEqualTo: minLongitude)
      .whereField("longitude", isLessThanOrEqualTo: maxLongitude)
    
    // Only apply type filtering if a specific type is selected
    if type != "none" {
      query = query.whereField("type", isEqualTo: type)
    }
    
    // Query Firestore with the bounding box and type filter,
    // can filter whatever we want just need to create an index in firebase
    query.limit(to: 15)
      .getDocuments { [weak self] (snapshot, error) in
        if let error = error {
          print("Error fetching documents: \(error.localizedDescription)")
          completion([])
          return
        }
        
        guard let documents = snapshot?.documents else {
          print("No documents found")
          completion([])
          return
        }
        
        print("Number of documents found: \(documents.count)") // Debug
        
        // Filter documents based on distance and add to the locations array
        let fetchedLocations = documents.compactMap { document in
          let data = document.data()
          let location = Location(id: document.documentID, data: data)
          
          let distanceInMeters = userLocation.distance(from: location.location) // User's Location
          print("Distance to location \(location.name): \(distanceInMeters) meters") // Debug
          
          // Filter locations based on radius
          if distanceInMeters <= radiusInMeters {
            print("Location \(location.name) is within radius")
            return location
          } else {
            print("Location \(location.name) is outside of radius")
          }
          return nil
        }
        
        // Select one random location if available
        if !fetchedLocations.isEmpty {
          let randomLocation = fetchedLocations.randomElement()!
          print("Randomly selected location: \(randomLocation.name)")
          
          self?.locations = [randomLocation]
          AuthViewModel.shared.saveAssignedLocation(randomLocation)  // Verwende Singleton für Speicherung
          completion([randomLocation])
        } else {
          completion([])
        }
      }
  }
  
}
