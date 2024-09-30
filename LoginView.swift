//
//  LoginView.swift
//  Challengify
//
//  Created by JASKIRAT SINGH on 2024-09-27.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    @State private var isShowingSignUp = false
    @State private var isShowingForgotPassword = false
    
    var body: some View {
        if isLoggedIn {
            ContentView() // Placeholder for the home screen after login
        } else {
            VStack {
                Spacer()
                
                // App Logo & Tagline
                VStack(spacing: 8) {
                    Text("Challengify")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                       
                    
                    Text("Make every day a little more exciting with daily challenges!")
                        .font(
                            .system(size: 16, weight: .medium, design: .default)
                        )
                        
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 50)

           
                
                // Email & Password Fields
                VStack(alignment: .leading, spacing: 16) {
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .shadow(color: Color.gray.opacity(0.1), radius: 5, x: 0, y: 5)
                    

                  
                       
                        SecureField("Password", text: $password)
         
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .shadow(color: Color.gray.opacity(0.1), radius: 5, x: 0, y: 5)
                    

                    // Forgot Password Link
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingForgotPassword.toggle()
                        }) {
                            Text("Forgot your password?")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding([.leading, .trailing], 32)
                
                // Login Button
                Button(action: {
                    loginUser()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.col1)
                        .cornerRadius(20)
                        .shadow(color: Color.col5.opacity(0.3), radius: 10, x: 0, y: 10)
                }
                .padding([.leading, .trailing, .top], 32)
                
                Spacer()

                // Sign Up Prompt
                HStack {
                    Text("Don’t have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        isShowingSignUp.toggle()
                    }) {
                        Text("Sign up here.")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
            }
            
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $isShowingSignUp) {
                SignupView() // Replace with your SignUpView
            }
            .sheet(isPresented: $isShowingForgotPassword) {
                //ForgotPasswordView() // Replace with your ForgotPasswordView
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Firebase Login Function
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            } else {
                self.isLoggedIn = true
            }
        }
    }
}



#Preview {
    LoginView()
}
