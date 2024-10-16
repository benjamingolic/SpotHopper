//
//  AuthViewModel.swift
//  SpotHopper
//
//  Created by Teodor Brankovic on 18.09.24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Class to manage user login, signup, and other functions
final class AuthViewModel: ObservableObject {
  
  static let shared = AuthViewModel()  // Singleton-Instanz
  
  @Published var user: User?
  @Published var selectedLocation: Location?
  @Published var visitedLocations: [Location] = []
  @Published var points: Double = 0
  @Published var hasCompletedOnboarding: Bool = false // Track if User finished Onboarding process!
  @Published var selectedRadius: Double?
  
  
  private init() {  // Privater Initialisierer, um Singleton zu erzwingen
    listenToAuthState()
  }
  
  func listenToAuthState() {
    Auth.auth().addStateDidChangeListener { [weak self]
      _, user in
      guard let self = self else {
        return
      }
      self.user = user
      
      // Lade die zugewiesen Location nur aus Firestore, wenn der Benutzer angemeldet ist
      if let user = user {
        self.hasCompletedOnboarding = true
        self.fetchAssignedLocation(uid: user.uid)
      } else {
        print("No user is currently logged in.")
      }
    }
  }
  
  // function to sign-in
  func signIn(emailAdress: String, password: String) {
    Auth.auth().signIn(withEmail: emailAdress, password: password) { result, error in
      if let error = error {
        print("Error Signing In")
        return
      }
    }
  }
  
  // function to create an account & store data in collection "users"
  func SignUp(emailAdress: String, password: String) {
    Auth.auth().createUser(withEmail: emailAdress, password: password) { result, error in
      if let error = error {
        print("Error Signing Up")
        return
      } else {
        print("Successfully created user with ID")
        guard let uid = Auth.auth().currentUser?.uid else {
          return
        }
        Firestore.firestore().collection("users").document(uid).setData(["email" : emailAdress, "uid": uid]) { err in
          if let err = err {
            print(err)
            return
          }
          print("success")
        }
      }
    }
  }
  
  // function to log out
  func signOut() {
    do {
      try Auth.auth().signOut()
      // Setze den Zustand zurück
      self.user = nil
      self.selectedLocation = nil
      self.visitedLocations = []
      self.hasCompletedOnboarding = false
      self.selectedRadius = nil // NEW: Reset selectedRadius on sign out
    } catch let signOutError as NSError {
      print("Error Signing Out")
    }
  }
  
  // Speichern der zugewiesenen Location in Firestore
  func saveAssignedLocation(_ location: Location) {
    guard let uid = user?.uid else { return }
    
    var timestamp = Timestamp(date: Date())
    let locationData: [String: Any] = [
      "locationID": location.id,
      "latitude": location.latitude,
      "longitude": location.longitude,
      "name": location.name,
      "style": location.style,
      "type": location.type,
      "assignedAt": timestamp,
      "selectedRadius": self.selectedRadius ?? 10
    ]
    
    // Speichere in Firestore
    Firestore.firestore().collection("users").document(uid).setData(["AssignedLocation": locationData], merge: true) { error in
      if let error = error {
        print("Error saving location: \(error.localizedDescription)")
      } else {
        // Aktualisiere die @Published selectedLocation nach dem Speichern
        DispatchQueue.main.async {
          self.fetchAssignedLocation(uid: uid)
        }
        print("Location successfully saved.")
      }
      
    }
  }
  
  // Abrufen der zugewiesenen Location aus Firestore
  func fetchAssignedLocation(uid: String) {
    let userRef = Firestore.firestore().collection("users").document(uid)
    userRef.getDocument { [weak self] (document, error) in
      if let document = document, document.exists, let data = document.data() {
        if let locationData = data["AssignedLocation"] as? [String: Any] {
          var location = Location(id: locationData["locationID"] as? String ?? "", data: locationData)
          
          // Convert the Timestamp back to Date
          if let timestamp = locationData["assignedAt"] as? Timestamp {
            location.assignedAt = timestamp.dateValue()
          }
          
          // NEW: Fetch selectedRadius from Firestore if it exists
          if let radius = locationData["selectedRadius"] as? Double {
            self?.selectedRadius = radius
          } else {
            self?.selectedRadius = 10 // Default radius if not present
          }
          
          // Update the selected location
          self?.selectedLocation = location
          print("Fetched location: \(location.name), assignedAt: \(String(describing: location.assignedAt))")
        }
      } else {
        print("No location found or error fetching data: \(error?.localizedDescription ?? "Unknown error")")
      }
    }
  }
  
  // Function to delete assignedLocation
  func deleteAssignedLocation() {
    guard let uid = user?.uid else { return }
    
    let userRef = Firestore.firestore().collection("users").document(uid)
    
    userRef.updateData([
      "AssignedLocation": FieldValue.delete() // Remove the assigned location
    ]) { error in
      if let error = error {
        print("Error deleting assigned location: \(error.localizedDescription)")
      } else {
        // Reset the selectedLocation in AuthViewModel
        DispatchQueue.main.async {
          self.selectedLocation = nil
        }
        print("Assigned location successfully deleted.")
      }
    }
  }
  
  
  // function to reset password
  func resetPassword(emailAddress: String) {
    Auth.auth().sendPasswordReset(withEmail: emailAddress)
  }
  
  // function to add points, dont use
  func addPoint(points: Double) {
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    
    // Reference to the user's document in Firestore
    let userRef = Firestore.firestore().collection("users").document(uid)
    
    // Fetch current points, add new points, and update the value
    userRef.getDocument { (document, error) in
      if let document = document, document.exists {
        if let currentPoints = document.data()?["points"] as? Double {
          let newPoints = currentPoints + points
          
          userRef.updateData(["points": newPoints]) { err in
            if let err = err {
              print("Error updating points: \(err)")
              return
            }
            print("Successfully added points")
            self.points += points
          }
        } else {
          // If points field does not exist, create it
          userRef.setData(["points": points], merge: true) { err in
            if let err = err {
              print("Error setting points: \(err)")
              return
            }
            print("Points initialized and added")
            self.points += points
          }
        }
      } else {
        print("Document does not exist or could not be retrieved")
      }
    }
  }
  
  // function to store visited locals of user, dont user
  func storeVisitedLocation(locationID: String, locationName: String, locationType: String, locationStyle: String) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let userRef = Firestore.firestore().collection("users").document(uid)
    
    // Store the location data in a dictionary
    let locationData = [
      "locationID": locationID,
      "name": locationName,
      "type": locationType,
      "style": locationStyle
    ]
    
    // Use arrayUnion to add the location data to the "visitedLocations" array
    userRef.updateData([
      "visitedLocations": FieldValue.arrayUnion([locationData])
    ]) { error in
      if let error = error {
        print("Error storing visited location: \(error)")
      } else {
        print("Successfully stored visited location")
      }
    }
  }
  
  
  // funtion to get points of user
  
  
  // function to fetch visited locals of user, dont use
  func fetchVisitedLocations() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let userRef = Firestore.firestore().collection("users").document(uid)
    
    userRef.getDocument { [weak self] document, error in
      if let error = error {
        print("Error fetching visited locations: \(error)")
        self?.visitedLocations = []  // Clear the array if there's an error
        return
      }
      
      if let document = document, document.exists {
        if let locationsArray = document.data()?["visitedLocations"] as? [[String: Any]] {
          // Map the dictionaries into Location objects
          let fetchedLocations: [Location] = locationsArray.compactMap { locationData in
            guard let id = locationData["locationID"] as? String else {
              return nil
            }
            
            return Location(id: id, data: locationData)
          }
          
          // Update the @Published variable
          self?.visitedLocations = fetchedLocations
          print("Successfully fetched visited locations")
        } else {
          self?.visitedLocations = []  // Clear the array if no locations are found
          print("No visited locations found for this user.")
        }
      } else {
        self?.visitedLocations = []  // Clear the array if the document doesn't exist
      }
    }
  }
  
  func completeOnboarding() {
    self.hasCompletedOnboarding = true
  }
  
}




