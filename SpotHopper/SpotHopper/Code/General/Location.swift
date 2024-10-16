//
//  Location.swift
//  SpotHopper
//
//  Created by Teodor Brankovic on 15.09.24.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import MapKit

struct Location: Identifiable, Equatable {
  let id: String
  let name: String
  let style: String
  let type: String
  let latitude: Double
  let longitude: Double
  var assignedAt: Date?  // New field for timestamp
  
  // New properties for travel time and polyline
  var travelTime: (driving: String, walking: String) = ("", "")
  var routePolyline: MKPolyline?
  var userRadius: Double?
  
  init(id: String, data: [String: Any]) {
    self.id = id
    self.name = data["name"] as? String ?? "No Name"
    self.style = data["style"] as? String ?? "Unknown Style"
    self.type = data["type"] as? String ?? "Unknown Type"
    self.latitude = data["latitude"] as? Double ?? 0.0
    self.longitude = data["longitude"] as? Double ?? 0.0
    self.assignedAt = data["assignedAt"] as? Date // Include assignedAt in the initializer if available
  }
  
  var location: CLLocation {
    return CLLocation(latitude: latitude, longitude: longitude)
  }
  
  // property for CLLocationCoordinate2D
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  // Manual implementation of the Equatable protocol
  static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.style == rhs.style &&
    lhs.type == rhs.type &&
    lhs.latitude == rhs.latitude &&
    lhs.longitude == rhs.longitude &&
    lhs.travelTime == rhs.travelTime
    // Note: We don't compare `routePolyline` since it's not Equatable.
  }
  
}
