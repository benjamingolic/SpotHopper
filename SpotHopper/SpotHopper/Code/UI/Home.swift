//
//  RequestView.swift
//  SpotHopper
//
//  Created by Benjamin Golic on 08.05.24.
//

import SwiftUI
import MapKit

struct Home: View {
  @EnvironmentObject var appState: AppState
  @State private var showingLocationOptions = false
  @State private var showingFilters = false
  @State private var showLocationCard = false
  @State private var buttonDisabled = false
  @State private var lockedButtonShakes: Int = 0
  
  @State private var radiusInKilometers: Double = 10
  
  @State private var filterMap: [String: String] = [
    // "What User sees": "FireBase String"
    "No Filter" : "none",
    "Cocktail & Shisha": "Cocktail & Shisha",
    "Restaurant": "Restaurant",
    "Fast Food": "Fast Food",
    "Bar with Kitchen": "Bar with Kitchen",
    "Café & Bar": "Cafe & Bar",
    "Café": "Cafe"
  ]
  @State private var selectedDisplayFilter: String = "No Filter"
  @State private var selectedFirebaseFilter: String = "none"
  
  @State private var selectedType = "Restaurant"
  
  @ObservedObject var locationModel = LocationViewModel()  // locationModel for database functions
  @EnvironmentObject var authModel: AuthViewModel
  
  @State private var countdownTime: TimeInterval = 86_400 // 24 hours in seconds
  @State private var countdownTimer: Timer?
  @State private var showCountdown: Bool = false
  
  @State private var hasVibratedForLocation = false
  
  var onMapTap: () -> Void
  
  var countdownDisplay: String {
    let hours = Int(countdownTime) / 3600
    let minutes = Int(countdownTime) / 60 % 60
    let seconds = Int(countdownTime) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
  
  func startCountdown(timeRemaining: TimeInterval) {
    countdownTime = timeRemaining
    countdownTimer?.invalidate() // Clear any existing timer
    countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      DispatchQueue.main.async {
        if self.countdownTime > 0 {
          self.countdownTime -= 1
        } else {
          self.countdownTimer?.invalidate()
          self.deleteLocationWhenTimeRunsOut() // NEW: Call deletion method
          hapticVibration(with: .warning)
          hasVibratedForLocation = false
        }
      }
    }
  }
  
  enum HapticFeedbackType {
    case success
    case warning
    case error
  }
  
  private var vibrationsEnabled: Bool {
    UserDefaults.standard.bool(forKey: "vibrationsEnabled")
  }
  
  func hapticVibration(with feedbackType: HapticFeedbackType) {
    if vibrationsEnabled {
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      
      switch feedbackType {
      case .success:
        generator.notificationOccurred(.success)
      case .warning:
        generator.notificationOccurred(.warning)
      case .error:
        generator.notificationOccurred(.error)
      }
    }
  }
  
  // NEW: Call AuthViewModel method to delete the assigned location
  func deleteLocationWhenTimeRunsOut() {
    authModel.deleteAssignedLocation()
    self.buttonDisabled = false
    self.showCountdown = false
    print("Assigned location deleted due to timer expiration.")
  }
  
  func calculateTimeRemaining(from assignedAt: Date) -> TimeInterval {
    let timeElapsed = Date().timeIntervalSince(assignedAt)
    let countdownDuration: TimeInterval = 86_400 // 24 hours in seconds
    return max(countdownDuration - timeElapsed, 0)
  }
  
  func resetCountdown() {
    countdownTime = 86_400 // Reset to 24 hours
    countdownTimer?.invalidate()
  }
  
  var body: some View {
    ZStack {
      Color(.bgColors)
        .ignoresSafeArea(.all)
      VStack {
        HStack {
          VStack(alignment: .trailing) {
            filtersBtn
          }
          
          // Slider for adjusting the search radius
          VStack(alignment: .leading) {
            Text("Search Radius: \(Int(radiusInKilometers)) km")
              .font(.custom("Supreme", size: 13))
              .foregroundStyle(.rbPurple)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.leading)
            
            
            Slider(value: $radiusInKilometers, in: 1...50, step: 1)
              .tint(.rbPurple)
              .padding(.horizontal)
              .disabled(buttonDisabled)
              .onChange(of: radiusInKilometers) {_, newValue in
                if Int(newValue) % 10 == 0 {
                  hapticVibration(with: .success)
                }
              }
          }
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        
        Spacer()
        
        if !buttonDisabled {
          Text("No plans? No problem.")
            .multilineTextAlignment(.center)
            .font(.custom("Supreme", size: 20))
            .fontWeight(.heavy)
            .foregroundStyle(.rbPurple)
            .padding(.bottom, 2)
          
          Text("Tap to discover a hidden gem nearby!")
            .multilineTextAlignment(.center)
            .font(.custom("Supreme", size: 17))
            .fontWeight(.semibold)
            .foregroundStyle(.rbPurple)
            .lineSpacing(2)
            .padding(.bottom, 10)
        }
        
        
        Button(action: { // fetch Button locationViewModel
          if buttonDisabled {
            withAnimation(.default) {
              lockedButtonShakes += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              lockedButtonShakes = 0
            }
            hapticVibration(with: .error)
          } else {
            print("Radius: \(radiusInKilometers) km")
            selectedType = selectedFirebaseFilter
            //authModel.selectedRadius = radiusInKilometers
            print(selectedType)
            
            locationModel.fetchLocations(type: selectedType, radiusInKilometers: radiusInKilometers) { locations in
              if let selectedLocation = authModel.selectedLocation  {
                print("selectedLocation: \(selectedLocation)")
                
                // NEW: Start countdown when location is fetched
                if let assignedAt = selectedLocation.assignedAt {
                  print("\(assignedAt) TEST TEST")
                  let timeRemaining = calculateTimeRemaining(from: assignedAt)
                  if timeRemaining > 0 {
                    countdownTime = timeRemaining // Update the countdown state
                    startCountdown(timeRemaining: timeRemaining)
                    showCountdown = true
                    print("countdown started at button")
                  }
                }
              }
            }
          }
        }) {
          HStack {
            if buttonDisabled {
              Image(systemSymbol: .lockFill)
            }
            Text("Give me a Spot")
              .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
            
            Image(systemSymbol: .chevronRight2)
              .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
            
          }
          .padding(.vertical, 15)
          .padding(.horizontal, 25)
          .font(.custom("Supreme", size: 17))
          .fontWeight(.bold)
          .background(
            buttonDisabled
            ? LinearGradient(
              gradient: Gradient(colors: [Color.gray, Color.gray]),
              startPoint: .top,
              endPoint: .bottom
            )
            : LinearGradient(
              gradient: Gradient(colors: [Color.rbPurple.opacity(0.8), Color.rbPurple]),
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .foregroundColor(.white)
          .cornerRadius(10)
          .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
          .scaleEffect(buttonDisabled ? 1.0 : 1.05)  // Add scaling effect
          .animation(.easeInOut(duration: 0.2), value: buttonDisabled)  // Animation on press
          
        }
        .modifier(Shake(animatableData: CGFloat(lockedButtonShakes)))
        
        // NEW: Display Countdown
        if showCountdown {
          Text("Next spot in: \(countdownDisplay)")
            .font(.headline)
            .foregroundColor(.rbPurple)
            .padding()
        }
        
        if showLocationCard {
          if let location = authModel.selectedLocation {
            LocationCardView(
              locationName: location.name,
              type: location.type,
              style: location.style,
              coordinate: location.coordinate,
              onMapTap: {
                onMapTap()
              }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding(.top, 20)
          }
          
        }
        Spacer()
      }
      .padding()
    }
    .onAppear {
      if let location = authModel.selectedLocation {
        withAnimation {
          showLocationCard = true
          buttonDisabled = true
        }
        
        if let radius = authModel.selectedRadius {
          radiusInKilometers = radius
          print("ON APPEAR RADIUS: \(radius)")
        }
        
        // NEW: If location has an assigned timestamp, start countdown
        if let assignedAt = location.assignedAt {
          let timeRemaining = calculateTimeRemaining(from: assignedAt)
          if timeRemaining > 0 {
            countdownTime = timeRemaining // Update countdown state
            startCountdown(timeRemaining: timeRemaining)
            showCountdown = true
            print("countdown started at onAppear")
          } else {
            self.deleteLocationWhenTimeRunsOut()
          }
        }
        calculateTravelTimesAndPolyline(for: location)
        
      }
    }
    .onChange(of: authModel.selectedLocation)  { _, newLocation in
      // This will update the button and card when selectedLocation changes
      if newLocation != nil {
        if !hasVibratedForLocation {
          hapticVibration(with: .success)
          hasVibratedForLocation = true
        }
        withAnimation {
          showLocationCard = true
          buttonDisabled = true
          showCountdown = true
        }
        
        if let radius = authModel.selectedRadius {
          radiusInKilometers = radius
          print("ON CHANGE RADIUS: \(radius)")
        }
        
        // NEW: Start countdown when selectedLocation is updated
        if let assignedAt = newLocation?.assignedAt {
          let timeRemaining = calculateTimeRemaining(from: assignedAt)
          if timeRemaining > 0 {
            countdownTime = timeRemaining // Update countdown state
            startCountdown(timeRemaining: timeRemaining)
            showCountdown = true
            print("countdown started at onChange")
          } else {
            self.deleteLocationWhenTimeRunsOut()
          }
        } else {
          print("AssignedAt is nil")
        }
        calculateTravelTimesAndPolyline(for: authModel.selectedLocation!)
      }
    }
    
    
  }
  
  // Method to calculate travel times and update AppState
  func calculateTravelTimesAndPolyline(for spot: Location) {
    print(" CALCULATE TRAVE TIME AND POLYLINE: \(spot)")
    guard let userLocation = locationModel.userLocation else { return }
    let userCoord = userLocation.coordinate
    
    // Create MKDirections request
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoord))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinate))
    request.requestsAlternateRoutes = false
    
    // Fetch driving time
    request.transportType = .automobile
    let drivingDirections = MKDirections(request: request)
    drivingDirections.calculate { response, error in
      if let route = response?.routes.first {
        authModel.selectedLocation?.routePolyline = route.polyline
        authModel.selectedLocation?.userRadius = radiusInKilometers
        authModel.selectedLocation?.travelTime.driving = "\(Int(route.expectedTravelTime / 60)) min"
      }
    }
    
    // Fetch walking time
    request.transportType = .walking
    let walkingDirections = MKDirections(request: request)
    walkingDirections.calculate { response, error in
      if let route = response?.routes.first {
        authModel.selectedLocation?.travelTime.walking = "\(Int(route.expectedTravelTime / 60)) min"
      }
    }
  }
  
  var filtersBtn: some View {
    HStack {
      Button(action: {
        
        showingFilters.toggle()
        hapticVibration(with: .success)
      }) {
        HStack {
          Image(systemSymbol: .line3HorizontalDecreaseCircle)
          Text(selectedDisplayFilter)
            .font(.custom("Supreme", size: 13))
        }
      }
      .padding(15)
      .background(!buttonDisabled ? Color.rbPurple: Color.gray)
      .foregroundColor(.white)
      .cornerRadius(10)
      .disabled(buttonDisabled)
    }
    .sheet(isPresented: $showingFilters) {
      VStack {
        Text("Select Filter").font(.headline).padding()
        Picker("Select a filter", selection: $selectedDisplayFilter) {
          ForEach(Array(filterMap.keys), id: \.self) { filter in
            Text(filter).tag(filter)
          }
        }
        .pickerStyle(.wheel)
        .padding()
        .onChange(of: selectedDisplayFilter) {_, newValue in
          // When user selects a filter, update the Firebase-friendly string
          selectedFirebaseFilter = filterMap[newValue] ?? "none"
        }
      }
      .presentationDetents([.height(250)])
    }
    
    .padding(.horizontal)
  }
}

struct Shake: GeometryEffect {
  var amount: CGFloat = 5
  var shakesPerUnit: CGFloat = 5
  var animatableData: CGFloat
  
  func effectValue(size: CGSize) -> ProjectionTransform {
    let translationX = amount * sin(animatableData * .pi * shakesPerUnit)
    return ProjectionTransform(CGAffineTransform(translationX: translationX, y: 0))
  }
}
