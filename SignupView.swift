//
//  SignupView.swift
//  Challengify
//
//  Created by JASKIRAT SINGH on 2024-09-27.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SignupView: View {
    // User details state
    @State private var name = ""
    @State private var age = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var goal = ""  // New Goal state variable
    @State private var selectedCategories: [String] = []
    
    // UI states
    @State private var step = 1
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSignUpSuccessful = false
    @State private var isShowingLogin = false
    
    let categories = ["Fitness", "Productivity", "Creativity", "Mindfulness",
                      "Learning", "Health", "Cooking", "Hobbies", "Self-Care",
                      "Relationships", "Finance", "Adventure", "Career", "Environment"]

    var body: some View {
        NavigationStack {
            VStack {
                
                if step == 1 {
                    // Step 1: Basic Information
                    Text("Step 1: Basic Info")
                        .font(
                            .system(
                                size: 22,
                                weight: .semibold ,
                                design: .rounded
                            )
                        )
                        .padding()
                    
                    TextField("Full Name", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    TextField("What is your goal?", text: $goal)
                        .keyboardType(.default)// New Goal input field
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: {
                        step = 2 // Move to next step
                    }) {
                        Text("Next")
                            .foregroundStyle(.black)
                            .font(
                                .system(
                                    size: 20,
                                    weight: .regular,
                                    design: .default
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.col1)
                        
                            .cornerRadius(20)
                    }
                    .padding()
                    .disabled(name.isEmpty || age.isEmpty || email.isEmpty || goal.isEmpty)
                }
                
                if step == 2 {
                    // Step 2: Category Selection
                    Text("Step 2: Select Interests")
                        .font(
                            .system(
                                size: 22,
                                weight: .semibold ,
                                design: .rounded
                            )
                        )
                        .padding()
                    
                    List(categories, id: \.self) { category in
                        Button(action: {
                            toggleCategory(category: category)
                        }) {
                            HStack {
                                Text(category)
                                Spacer()
                                if selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        step = 3 // Move to next step
                    }) {
                        Text("Next")
                            .foregroundStyle(.black)
                            .font(
                                .system(
                                    size: 20,
                                    weight: .regular,
                                    design: .default
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.col1)
                        
                            .cornerRadius(20)
                    }
                    .padding()
                    .disabled(selectedCategories.isEmpty)
                }
                
                if step == 3 {
                    // Step 3: Password Setup
                    Text("Step 3: Set Your Password")
                        .font(
                            .system(
                                size: 22,
                                weight: .semibold ,
                                design: .rounded
                            )
                        )
                        .padding()
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)
                    
                    if !password.isEmpty && password != confirmPassword {
                        Text("Passwords do not match!")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        if password == confirmPassword {
                            signUpUser() // Sign up process
                        } else {
                            errorMessage = "Passwords do not match"
                            showErrorAlert = true
                        }
                    }) {
                        Text("Sign up")
                            .foregroundStyle(.black)
                            .font(
                                .system(
                                    size: 20,
                                    weight: .regular,
                                    design: .default
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                        
                            .cornerRadius(20)
                    }
                    
                    .padding()
                    .disabled(password.isEmpty || confirmPassword.isEmpty)
                    
                    
                }
                
                HStack {
                    Text("Have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        isShowingLogin.toggle()
                    }) {
                        Text("Login")
                            .fontWeight(.bold)
                            .foregroundColor(.col3)
                    }
                }
                .padding(.bottom, 20)
        
                
            }
            .navigationDestination(isPresented: $isShowingLogin) {
                LoginView()
                        }
            .navigationDestination(isPresented: $isSignUpSuccessful) {
                ContentView()
                        }
            .padding()
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
        }
        
    }
        
    
    // Toggle category selection
    func toggleCategory(category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }

    // Sign Up and store additional data in Firestore
    func signUpUser() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            } else if let authResult = authResult {
                saveUserData(uid: authResult.user.uid)
                isSignUpSuccessful = true
            }
        }
    }

    // Save additional user data to Firestore
    func saveUserData(uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "name": name,
            "age": age,
            "goal": goal, // Save goal to Firestore
            "categories": selectedCategories
        ]) { err in
            if let err = err {
                errorMessage = "Error saving user data: \(err.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
}



#Preview {
    SignupView()
}
