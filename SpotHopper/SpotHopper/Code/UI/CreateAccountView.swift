//
//  CreateAccountView.swift
//  SplinePlayground
//
//  Created by Benjamin Golic on 18.09.24.
//

import SwiftUI

struct CreateAccountView: View {
  var onNext: () -> Void
  @State private var isLoginMode = false
  @State private var showInputFields = false // State for showing the input fields
  @State private var name = ""
  @State private var surname = ""
  @Binding var email: String
  @Binding var password: String
  @State private var confirmPassword = ""
  @State private var passwordsMatch = true
  @State private var isPasswordLengthValid = true
  @State private var errorMessage: String?
  
  @FocusState private var focusedField: Field?
  enum Field: Hashable {
    case name, surname, email, password, confirmPassword
  }
  
  @EnvironmentObject private var authModel: AuthViewModel
  
  var body: some View {
    VStack {
      
      Lottie(lottieFile: "LottieRegLog.json")
        .frame(maxWidth: .infinity, maxHeight: {
          if focusedField != nil {
            return isLoginMode ? 300 : 150
          } else {
            return 500
          }
        }())
        .background(.cecece)
        .animation(.easeInOut, value: focusedField)
        .ignoresSafeArea()
        .onTapGesture {
          focusedField = nil
        }
      
      if !showInputFields {
        VStack(spacing: 12) {
          Text("Create Account")
            .font(.title.bold())
          
          Text("Sign up or log in to receive personalized spot recommendations every day.")
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        
        Spacer()
        
        HStack(spacing: 20) {
          Button(action: {
            withAnimation(.easeInOut) {
              isLoginMode = false
              showInputFields = true
            }
          }) {
            HStack {
              Text("Sign Up")
              Image(systemName: "person.crop.circle.badge.plus")
            }
          }
          .padding(15)
          .background(Color.rbPurple)
          .foregroundColor(.white)
          .cornerRadius(10)
          
          Button(action: {
            withAnimation(.easeInOut) {
              isLoginMode = true
              showInputFields = true
            }
          }) {
            HStack {
              Text("Log In")
              Image(systemName: "person.crop.circle")
            }
          }
          .padding(15)
          .background(Color.gray)
          .foregroundColor(.white)
          .cornerRadius(10)
        }
        .padding(.horizontal)
        
        Spacer()
      } else {
        VStack(spacing: 12) {
          Text(isLoginMode ? "Log In" : "Create Account")
            .font(.title.bold())
            .transition(.opacity)
          
          if isLoginMode {
            Text("Enter your email and password to access your account.")
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
          } else {
            Text("Sign up to receive personalized spot recommendations every day.")
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
          }
        }
        .onTapGesture {
          focusedField = nil
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.8), value: isLoginMode)
        
        Spacer()
        
        ScrollViewReader { scrollView in
          ScrollView {
            VStack(spacing: 12) {
              if !isLoginMode {
                Group {
                  TextField("First Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .name)
                  TextField("Last Name", text: $surname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .surname)
                }
                .animation(.easeOut, value: !isLoginMode)
              }
              
              TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .focused($focusedField, equals: .email)
              
              SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .password)
                .onChange(of: password) {
                  isPasswordLengthValid = password.count >= 6
                }
              
              if !isLoginMode {
                SecureField("Confirm Password", text: $confirmPassword)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .focused($focusedField, equals: .confirmPassword)
                  .onChange(of: confirmPassword) { _, newValue in
                    passwordsMatch = (password == newValue)
                    isPasswordLengthValid = password.count >= 6
                  }
                
                if !isPasswordLengthValid {
                  Text("Password must be at least 6 characters")
                    .foregroundColor(.red)
                    .font(.caption)
                    .transition(.opacity)
                }
                
                if !passwordsMatch {
                  Text("Passwords do not match")
                    .foregroundColor(.red)
                    .font(.caption)
                    .transition(.opacity)
                }
              }
            }
            .padding()
            .animation(.spring(), value: isLoginMode)
            
            Spacer()
            
            Button(action: {
              focusedField = nil
              if !isLoginMode && password != confirmPassword {
                passwordsMatch = false
                return
              }
              
              if isLoginMode {
                // Call `signIn` function
                authModel.signIn(emailAdress: email, password: password)
                //onNext() // Move to the next view if needed
              } else {
                // Call `signUp` function
                //authModel.SignUp(emailAdress: email, password: password)
                onNext() // Move to the next view if needed
                //authModel.completeOnboarding()
              }
              
            }) {
              HStack {
                Text(isLoginMode ? "Log In" : "Sign Up")
                Image(systemName: isLoginMode ? "person.crop.circle.fill" : "person.crop.circle.badge.plus")
              }
            }
            .padding(15)
            .background(passwordsMatch && isPasswordLengthValid ? Color.rbPurple : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoginMode ? email.isEmpty || password.isEmpty : email.isEmpty || password.isEmpty || name.isEmpty || surname.isEmpty || !passwordsMatch || !isPasswordLengthValid)
            //option2:
          }
        }
        Button(action: {
          withAnimation {
            isLoginMode.toggle()
          }
        }) {
          Text(isLoginMode ? "Don't have an account? Sign up now" : "Already have an account? Log in")
            .foregroundColor(.gray)
        }
        .padding(.top, 10)
        
        Spacer()
      }
      
    }
    .ignoresSafeArea(edges: .top)
    .scrollDismissesKeyboard(.interactively)
    .onAppear {
      passwordsMatch = true
    }
  }
}
