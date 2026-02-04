//
//  HomeView.swift
//  DSAKit
//
//  Created by admin on 1/24/26.
//

import Foundation
import SwiftUI
import SwiftData

struct HomeView: View {
    var onClose: () -> Void
    
    var body: some View {
        
        #if DEBUG
        let _ = Self._printChanges()
        #endif

        VStack() {
            
            Color.clear
                .frame(maxWidth: .infinity).frame(height:60)
                .overlay(alignment: .topLeading) {
                    Button(action: {
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16)).fontWeight(.bold)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                }
            
            GeminiKeyView()
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .padding(.horizontal, 30)
            
            ChallengesView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    struct GeminiKeyView: View {
        
        @AppStorage("geminiAPIKey") var apiKey = ""
        @FocusState var isTextFieldFocused: Bool
                
        var body: some View {

            #if DEBUG
            let _ = Self._printChanges()
            #endif

            HStack {
                Text("Gemini API Key: ")
                    .font(.system(size:14))
                    .fontWeight(.bold)
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 6)
                    TextField("", text: $apiKey)
                        .textFieldStyle(.plain)
                        .font(.system(size:14))
                        .padding(.horizontal, 5)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            isTextFieldFocused = false
                        }
                    Divider()
                        .padding(.vertical, 2)
                }
            }

        }
    }
    
    struct ChallengesView: View {
        
        @State var selectedChallengeID = ""
        
        @EnvironmentObject var selectedChallenge: DSAKitApp.ObservableChallenge

        @Query var challenges: [ChallengeItem]
        @Environment(\.modelContext) var modelContext: ModelContext

        var body: some View {
                        
            #if DEBUG
            let _ = Self._printChanges()
            #endif

            VStack(spacing: 3) {
                
                // Header Section
                HStack(spacing: 10) {
                    Text("Challenges")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        
                        selectedChallenge.challenge = ChallengeItem(challegeId: "leetcode", title: "", url: "https://leetcode.com/problemset/", src: "", timestamp: Date())
                        
                    } label: {
                        Image("leetcode-logo") // The name in your Asset Catalog
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20) // Adjust icon size as needed
                    }
                    .buttonStyle(.plain)
                    .frame(width: 40, height: 40)
                    
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 3)
                
                // Divider
                Divider()
                    .padding(.horizontal, 15)
                    .padding(.vertical, 3)

                // List Section
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(challenges) { challenge in
                            
                            HStack {
                                Text(challenge.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.clear)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 15)

                                Button(action: {
                                    
                                    let process = Process()
                                    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                                    process.arguments = ["-a", "Visual Studio Code", challenge.src]
                                    try? process.run()

                                }) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                        .frame(width: 40, height: 40)
                                }
                                .buttonStyle(.plain)
                            }
                            .background(selectedChallengeID == challenge.challegeId ? Color.gray.opacity(0.1) : Color.clear)
                            .contentShape(Rectangle()) // Makes the whole area tappable
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    selectedChallengeID = challenge.challegeId
                                }
                                
                                Task {
                                    // Sleep for 200 milliseconds
                                    try? await Task.sleep(for: .milliseconds(200))
                                    
                                    withAnimation {
                                        selectedChallengeID = ""
                                    }
                                    
                                    selectedChallenge.challenge = challenge
                                }
                                
                            }
                            
                            Divider()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 30)

            }
            
        }
        
    }

}

