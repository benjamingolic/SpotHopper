//
//  AppState.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 17.09.24.
//

import Foundation
import MapKit


class AppState: ObservableObject {
  var selectedSpot: Location? // The random given spot to the user
  var travelTime: (driving: String, walking: String) = ("","")
  var routePolyline: MKPolyline?
}
