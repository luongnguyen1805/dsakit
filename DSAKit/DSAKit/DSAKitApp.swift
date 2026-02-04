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
            ContentView(webStore: webStore)
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
                
        final class ScriptHandler: NSObject, WKScriptMessageHandler {
                        
            var onActualUrlFound: ((String) -> ())?
            
            func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
                
                guard message.name == "routeChanged",
                  let body = message.body as? [String: Any],
                  let url = body["url"] as? String
                else { return }

                if let onActualUrlFound = onActualUrlFound {
                    onActualUrlFound(url)
                }

            }
        }
                
        var webView: WKWebView
        var scriptHandler: ScriptHandler
        @Published var actualUrl: String = ""

        init() {
            webView = WKWebView()
            webView.customUserAgent =
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
                "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
                "Version/17.0 Safari/605.1.15"
                        
            let script = WKUserScript(
                source: """
            (function () {
              let lastUrl = "";

              function actual_url_report() {
                const currentUrl = location.href;
                if (currentUrl !== lastUrl) {
                  lastUrl = currentUrl;

                  window.webkit.messageHandlers.routeChanged.postMessage({
                    url: currentUrl
                  });
                }
              }

              // run every 100ms
              setInterval(actual_url_report, 100);

            })();
            """,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )

            webView.configuration.userContentController = WKUserContentController()
            webView.configuration.userContentController.addUserScript(script)
            
            scriptHandler = ScriptHandler()
            scriptHandler.onActualUrlFound = { [weak self] aurl in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return
                    }
                    self.actualUrl = aurl
                }
            }
            
            webView.configuration.userContentController.add(scriptHandler, name: "routeChanged")
        }
        
    }
    
}
