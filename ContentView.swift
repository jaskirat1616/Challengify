//
//  ContentView.swift
//  Challengify
//
//  Created by JASKIRAT SINGH on 2024-09-27.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleGenerativeAI

extension LocalizedStringKey {
    var stringValue: String {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let value = child.value as? String {
                return value
            }
        }
        return ""
    }
}

struct TextMarkdown: View {
    
    let markdown: LocalizedStringKey
    
    init(_ content: String) {
        markdown = LocalizedStringKey(content)
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(formatText(markdown.stringValue), id: \.self) { line in
                if (line.hasPrefix("## ") || line.hasPrefix("##") || line.hasPrefix("##  ")){
                    let cleanedLine = line
                        .replacingOccurrences(of: "##  ", with: "")
                        .replacingOccurrences(of: "## ", with: "")
                        .replacingOccurrences(of: "##", with: "")
                    Text(cleanedLine)
                        .font(
                            .system(
                                size: 35,
                                weight: .semibold,
                                design: .default
                            )
                        )
                        .foregroundColor(Color.col7)
                     
                        .padding(.init(
                            top: 0, leading: 0, bottom: 10, trailing: 0
                        ))
                }
                else{
                    Text(line.replacingOccurrences(of: "**", with: ""))
                        .font(.system(size: 18, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .padding(.init(
                            top: 0, leading: 0, bottom: 10, trailing: 0
                        ))
                }
            }
        }
    }
    func formatText(_ text: String) -> [String] {
        text.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } // Remove empty lines
    }
}
struct ContentView: View {
    @State private var errorMessage = ""
    @State private var userGoal = ""
    @State private var selectedCategories: [String] = []
    @State private var ProfileShower: Bool = false
    @State private var ChallengeText: String = ""
    @State private var isUserSignedIn: Bool = true
    @State private var logout: Bool = false
    @State private var goalCompleted: Bool = false
    var body: some View {
        
        
        
        NavigationStack {
                GeometryReader {
                    geo in
                    ScrollView {
                        VStack(alignment: .center, spacing: 0) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.col6)
                                .frame(
                                    height: geo.size.height * 0.6,
                                    alignment: .top
                                )
                            
                                .overlay{
                                    ScrollView {
                                        
                                        
                                        TextMarkdown(
                                            ChallengeText.isEmpty ? """
                                            
                                            ##  Mindful Minutes
                                            Take 5 minutes to actively listen to someone you care about. Try to understand their perspective without interrupting or offering advice.  This will help you develop empathy and build stronger relationships.
                                            
                                            **Recommended time:** 5 minutes
                                            
                                            **Completion criteria:**  Engage in a genuine conversation where you focus on listening more than talking.
                                            
                                            **Motivation:**  Being a good listener is a powerful skill that can improve your emotional intelligence and create stronger connections.
                                            """ : ChallengeText
                                        )
                                        
                                        
                                        .foregroundStyle(Color.col7)
                                        
                                        TextMarkdown(ChallengeText)
                                        
                                        
                                            .foregroundStyle(Color.col7)
                                        
                                    }
                                    .padding()
                                    
                                }
                            Spacer()
                            RoundedRectangle(cornerRadius: 20)
                                                        .foregroundStyle(Color.col2)
                                                        .frame(height: geo.size.height * 0.2)
                                                        .overlay {
                                                          
                                                            VStack(
                                                                
                                                                spacing: 5
                                                                
                                                            ) {
                                                                Text("My Goal")
                                                                    .foregroundStyle(
                                                                        Color.col7
                                                                    )
                                                                    .font(
                                                                        .system(
                                                                            size: 24, weight: .semibold, design: .rounded
                                                                        )
                                                                        
                                                                    )
                                                                    
                                               
                                                                Text(userGoal)
                                                                    .foregroundStyle(
                                                                        Color.col7
                                                                    )
                                                                    .font(
                                                                        .system(
                                                                            size: 20, weight: .medium, design: .rounded
                                                                        )
                                                                    )
                                                                   
                                                            }
                                                            
                                                                
                                                                // Mark Goal as Done Button
                                                                
                                                            }
                            Spacer()
                            Button(action: {
                                completeChallenge()
                            }) {
                                Text(goalCompleted ? "Goal Completed" : "Mark as Done")
                                    .font(.headline)
                                    .padding()
                                    .background(
                                        goalCompleted ? Color.col5 : Color
                                            .col3)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                            .padding()
                            .disabled(goalCompleted)
                        }
                        
                        .toolbar{
                            
                            ToolbarItem(placement: .topBarTrailing){
                                Button{
                                    signOut()
                                }label: {
                                    Text("Sign Out")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                    
                                    
                                }
                            }
                            ToolbarItem(placement: .topBarLeading){
                                Button{
                                    ProfileShower.toggle()
                                }label: {
                                    Image(systemName: "person.crop.circle")
                                    
                                        .foregroundStyle(Color.secondary)
                                    
                                    
                                }
                            }
                            
                            
                        }
                        .navigationDestination(isPresented: $logout) {
                            WelcomeView()
                                    }
                        
                        
                        
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarTitleDisplayMode(.inline
                        )
                        .navigationTitle("Challengify")
                        
                        
                        .sheet(isPresented: $ProfileShower){
                            UserProfileView()
                        }
                        .padding(8)
                        .onAppear {
                            // Load the challenge and goal from UserDefaults
                            
                            if shouldFetchNewChallenge() {
                                Task {
                                    fetchUserGoal()
                                }
                                
                            }else{
                                loadStoredChallengeAndGoal()
                            }
                        }
                    }
                    .refreshable {
                        checkUserSignInStatus()
                        if goalCompleted == true {
                            Task {
                                fetchUserGoal()
                                goalCompleted.toggle()
                            }
                        }
                        
                    }
                    
                }
            }
        
        .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
           
            
            
            
        
        
    }
    func completeChallenge() {
            let db = Firestore.firestore()
            if let user = Auth.auth().currentUser {
                let completedChallenge = [
                    "challengeText": ChallengeText,
                    "status": "done",
                    "timestamp": Timestamp()
                ] as [String: Any]
                
                db.collection("users").document(user.uid).collection("completedChallenges").addDocument(data: completedChallenge) { error in
                    if let error = error {
                        print("Error saving challenge: \(error.localizedDescription)")
                    } else {
                        print("Challenge marked as done!")
                        goalCompleted = true
                    }
                }
            }
        }
        
        func fetchUserGoal() {
            let db = Firestore.firestore()
            if let user = Auth.auth().currentUser {
                db.collection("users").document(user.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.userGoal = document.data()?["goal"] as? String ?? "No goal found"
                        self.selectedCategories = document.data()?["categories"] as? [String] ?? []
                        
                        Task {
                            await generateDailyChallenge(
                                goal: userGoal,
                                categories: selectedCategories
                            )
                        }
                        saveLastFetchDate()
                        saveChallengeAndGoal(challenge: ChallengeText, goal: userGoal)
                        
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
        
        func generateDailyChallenge(goal: String, categories: [String]) async {
            let model = GenerativeModel(
                name: "gemini-1.5-flash",
                apiKey: APIKey.default,
                systemInstruction: """
    You are an AI tasked with generating personalized daily challenges for users. Each user provides a specific goal and selects categories of interest. Based on this information, create a unique, concise, and engaging daily challenge that aligns with their goal and chosen categories. The challenge should be achievable within one day, cool, and fun. Challenges should be unique with cool titles
    
    Ensure that your output follows this structure:
    
    Output Format:
    A short, catchy title for the challenge.
    A brief description explaining the challenge and its benefits.
    Recommended time to complete the challenge.
    Clear criteria for the user to prove completion of the challenge.
    A motivational message to inspire the user.
    

    
    the title must have ## before it

    """
                
                
            )
            
            
            let prompt = """
            Generate a unique daily challenge for a user based on the following information:
            - User's goal: \(goal)
            
            The challenge should be fun, concise, and achievable within a day.
            """
            
            
            Task {
                do {
                    let response = try await model.generateContent(prompt)
                    
                    ChallengeText = response.text ?? ""
                    print(ChallengeText)
                    
                } catch {
                    print("Something went wrong!\n\(error.localizedDescription)")
                }
            }
        }
        
        func formatText(_ text: String) -> [String] {
            text.components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } // Remove empty lines
        }
    
    
    func checkUserSignInStatus() {
            isUserSignedIn = Auth.auth().currentUser != nil
            if !isUserSignedIn {
                print(isUserSignedIn)
                print("User is not signed in.")
            } else {
                
                print("User is signed in.")
            }
        }
    func signOut() {
            do {
                try Auth.auth().signOut()
                logout.toggle()
                
                // Optionally navigate to the login screen here
                // If you're using a navigation model, you can set the root view
            } catch let signOutError as NSError {
                errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            }
        }
    func saveLastFetchDate() {
            let currentDate = Date()
            UserDefaults.standard.set(currentDate, forKey: "lastFetchDate")
        }

        // Save challenge and goal to UserDefaults
        func saveChallengeAndGoal(challenge: String, goal: String) {
            UserDefaults.standard.set(challenge, forKey: "storedChallengeText")
            UserDefaults.standard.set(goal, forKey: "storedUserGoal")
        }

        // Load challenge and goal from UserDefaults
    func loadStoredChallengeAndGoal() {
        if let storedChallenge = UserDefaults.standard.string(forKey: "storedChallengeText") {
            ChallengeText = storedChallenge // Load saved challenge
        } else {
            ChallengeText = "Default challenge text" // Provide a fallback
        }

        if let storedGoal = UserDefaults.standard.string(forKey: "storedUserGoal") {
            userGoal = storedGoal // Load saved goal
        } else {
            userGoal = "Default goal" // Provide a fallback
        }
    }
    func shouldFetchNewChallenge() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Check if the goal is completed, if so, we fetch a new one.
        if goalCompleted {
            return true
        }
        
        // Retrieve the last fetch date from UserDefaults, and check if it exists
        if let lastFetchDate = UserDefaults.standard.object(forKey: "lastFetchDate") as? Date {
            // Check if the last fetch was on the same day
            if calendar.isDate(lastFetchDate, inSameDayAs: currentDate) {
                return false // Same day, no need to fetch
            }
        }
        
        return true // Either no last fetch or it's a new day, fetch the challenge
    }
}

#Preview {
    ContentView()
}
