//
//  DSAKitApp.swift
//  DSAKit
//
//  Created by admin on 1/23/26.
//

import SwiftUI
import SwiftData
import WebKit

@main
struct DSAKitApp: App {
        
    var modelContainer: ModelContainer = {
        let schema = Schema([
            ChallengeItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var states = States()
    var stateKey = ""
    
    var webStore = WebViewStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(webStore: webStore, stateKey: "\(stateKey)/ContentView")
                .frame(minWidth: 500, minHeight: 500)
                .environmentObject(states)
                .onAppear {
                    print("SwiftData Path: \(modelContainer.configurations.first?.url.path ?? "Unknown")")
                }
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 800, height: 600)
        .windowStyle(.automatic)
        .modelContainer(modelContainer)
    }
    
    final class ObservableChallenge: ObservableObject {
        @Published var challenge: ChallengeItem? = nil
    }

    final class States: ObservableObject {
        var of:[String:Any] = [:]
    }
        
    final class WebViewStore: ObservableObject {
        var webView: WKWebView
        
        init() {
            webView = WKWebView()
            webView.customUserAgent =
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
                "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
                "Version/17.0 Safari/605.1.15"
        }
    }
    
}
