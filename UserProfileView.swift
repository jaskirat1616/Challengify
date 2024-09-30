//
//  UserProfileView.swift
//  Challengify
//
//  Created by JASKIRAT SINGH on 2024-09-27.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserProfileView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var goal: String = ""
    @State private var newGoal: String = "" // Store edited goal
    @State private var loading = true
    @State private var errorMessage = ""
    @State private var isEditingGoal = false // Toggle editing mode
    @State private var backtowelcome = false
    var body: some View {
        NavigationStack {
            ZStack {
                // Cool background gradient
                LinearGradient(
                    gradient: Gradient(
                        colors: [Color.col1, Color.col5]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                if loading {
                    ProgressView("Loading profile...")
                        .foregroundColor(.gray)
                } else if !errorMessage.isEmpty {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    VStack(alignment: .leading, spacing: 30) {
                        Spacer(minLength: 5)
                        // Profile section with name and age
                        VStack(alignment: .leading, spacing: 0) {
                            Text(name)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.init(top: 10, leading: 10, bottom: 0, trailing: 10))
                            
                            Text("Age: \(age)")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.init(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                        
                        .background(Color.white.opacity(0.2)) // Light translucent background
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Divider for clean separation
                        Divider()
                            .background(Color.white.opacity(0.5))
                            .padding(.horizontal)
                        
                        // Goal section with minimal edit functionality
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Goal")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            
                            if isEditingGoal {
                                TextField("Enter new goal", text: $newGoal)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 18, design: .rounded))
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(8)
                                
                                // Minimalistic save button
                                Button(action: {
                                    updateGoalInFirestore()
                                }) {
                                    Text("Save")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                                .padding(.top, 10)
                            } else {
                                // Display goal with an edit icon
                                HStack {
                                    Text(goal)
                                        .font(.system(size: 18, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    // Edit icon
                                    Button(action: {
                                        isEditingGoal.toggle()
                                        newGoal = goal
                                    }) {
                                        Text("Edit Goal")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        
                        Spacer()
                        
                    }
                    
                }
                
            }.navigationTitle("My Profile")
        }
            
                    .onAppear(perform: fetchUserData)
                    
                    
            }
    
    
            
            
            // Fetch user data from Firestore
            func fetchUserData() {
                guard let uid = Auth.auth().currentUser?.uid else {
                    errorMessage = "User not authenticated"
                    loading = false
                    return
                }
                
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(uid)
                
                docRef.getDocument { document, error in
                    loading = false
                    if let error = error {
                        errorMessage = "Error fetching user data: \(error.localizedDescription)"
                    } else if let document = document, document.exists {
                        let data = document.data()
                        self.name = data?["name"] as? String ?? "Unknown"
                        self.age = data?["age"] as? String ?? "Unknown"
                        self.goal = data?["goal"] as? String ?? "Unknown"
                    } else {
                        errorMessage = "No user data found"
                    }
                }
            }
            
            // Update the goal in Firestore
            func updateGoalInFirestore() {
                guard let uid = Auth.auth().currentUser?.uid else {
                    errorMessage = "User not authenticated"
                    return
                }
                
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(uid)
                
                // Update the "goal" field in Firestore
                docRef.updateData(["goal": newGoal]) { error in
                    if let error = error {
                        errorMessage = "Error updating goal: \(error.localizedDescription)"
                    } else {
                        self.goal = newGoal // Update local state
                        isEditingGoal = false // Exit editing mode
                    }
                }
            }
    
        
    
}


#Preview {
    UserProfileView()
}
