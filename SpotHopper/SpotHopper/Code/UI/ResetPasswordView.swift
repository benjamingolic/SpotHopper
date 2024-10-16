//
//  ResetPasswordView.swift
//  SpotHopper
//
//  Created by Teodor Brankovic on 18.09.24.
//

import SwiftUI

struct ResetPasswordView: View {
  @State private var emailAddress: String = ""
  @EnvironmentObject var authModel: AuthViewModel
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Email", text: $emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
        }
        
        Section(footer: Text("Once sent, check your email to reset your password.")) {
          Button(action: {
            authModel.resetPassword(emailAddress: emailAddress)
          }) {
            Text("Send email link").bold()
          }
        }
      }
      .navigationTitle("Reset password")
      .toolbar {
        ToolbarItemGroup(placement: .confirmationAction) {
          Button("Done") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
    }
    
  }
}

//#Preview {
//    ResetPasswordView()
//}

