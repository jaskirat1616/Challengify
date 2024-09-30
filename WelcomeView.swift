//
//  WelcomeView.swift
//  Challengify
//
//  Created by JASKIRAT SINGH on 2024-09-27.
//

import SwiftUI
import FirebaseAuth


struct RootView: View {
    @State private var isSignedIn = false
    @State private var loading = true
    
    
    var body: some View {
        Group {
            if loading {
                ProgressView("Checking authentication status...")
            } else {
                if isSignedIn {
                    // If the user is signed in, navigate to ContentView
                    ContentView()
                } else {
                    // If the user is not signed in, navigate to LoginView
                    LoginView()
                }
            }
        }
        .onAppear(perform: checkAuthStatus)
    }
    
    // Check Firebase Authentication status
    func checkAuthStatus() {
        if Auth.auth().currentUser != nil {
            // User is signed in
            isSignedIn = true
        } else {
            // No user is signed in
            isSignedIn = false
        }
        loading = false
    }
}
struct WelcomeView: View {
    var body: some View {

            ZStack{
                Image("WelcomeImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.4)
                    .background(Color.black)
                
                
                VStack{
                    Spacer()
                    Text("Challengify")
                        .opacity(0.7)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white) // Change the text color as needed
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    VStack{
                        Text("Hit Get Started to set your goals and dive into your first challenge!")
                            .font(
                                .system(
                                    size: 12,
                                    weight: .regular,
                                    design: .default
                                )
                            )
                            .fontWeight(.regular)
                            .padding()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
                        
                        NavigationLink(destination: RootView()) {
                            Text("Get Started")
                            
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(EdgeInsets.init(top: 15, leading: 30, bottom: 15, trailing: 30))
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .cornerRadius(10)
                        }
                    }
                    
                }
                
                
                
                
                
                
            }
            .navigationBarBackButtonHidden()
        }
   
            
        
    }
    


#Preview {
    WelcomeView()
}
