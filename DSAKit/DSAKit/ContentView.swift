//
//  ContentView.swift
//  DSAKit
//
//  Created by admin on 1/23/26.
//

import SwiftUI
import SwiftData
import WebKit

struct ContentView: View {
            
    @State var processor: Processor?
    
    @State var canGoBack = false
    @State var canGoForward = false
    @State var loadingProgress = 0.0
    
    @State var showHomeView = false
    
    @State var showProcessingView = false
    
    @State var alertShowing = false
    @State var alertTitle = ""
    @State var alertMsg = ""
    
    @FocusState var isTextFieldFocused: Bool
    
    @StateObject var selectedChallenge = DSAKitApp.ObservableChallenge()

    @State var urlAddress = ""
        
    @AppStorage("lastSavedBrowsingAddress")
    var lastSavedBrowsingAddress = ""
    
    @AppStorage("geminiAPIKey")
    var geminiAPIKey = ""

    @ObservedObject var webStore: DSAKitApp.WebViewStore

    @Environment(\.modelContext) var modelContext: ModelContext
    
    @EnvironmentObject var states: DSAKitApp.States
        
    var stateKey = ""
            
    var body: some View {
        ZStack {
            mainView
            
            if showProcessingView {
                ZStack {
                    Color.black
                        .opacity(0.6)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    ProgressView()
                        .progressViewStyle(.circular)
                        .colorInvert()
                        .scaleEffect(1.3)
                }
            }
            
            if showHomeView {
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
                
                ZStack {
                    HomeView {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showHomeView = false
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .cornerRadius(16)
                    .environmentObject(selectedChallenge)
                    .onChange(of: selectedChallenge.challenge) { oldValue, newValue in
                        
                        guard let challenge = selectedChallenge.challenge else {
                            return
                        }
                        
                        showHomeView = false
                        urlAddress = challenge.url
                        lastSavedBrowsingAddress = challenge.url
                        loadURL()
                        
                    }
                    
                }.padding(30)
                .transition(.opacity)
                .zIndex(2)
                
            }
        }
        .alert(alertTitle, isPresented: $alertShowing) {
            Button("OK") {                 
            }
        } message: {
            Text(alertMsg)
        }.onAppear {
            
            if (urlAddress.lengthOfBytes(using: .utf8) == 0 && lastSavedBrowsingAddress.lengthOfBytes(using: .utf8) > 0) {
                
                urlAddress = lastSavedBrowsingAddress
                loadURL()
            }
            
        }
    }

    var mainView: some View {
        
        VStack(spacing:0) {
            
            HStack(spacing:0) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showHomeView.toggle()
                    }
                }) {
                    Image(systemName: "line.3.horizontal.circle")
                        .font(.system(size: 16))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 6)
                    TextField("Type URL", text: $urlAddress)
                        .textFieldStyle(.plain)
                        .font(.system(size:14))
                        .padding(.horizontal, 5)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            isTextFieldFocused = false
                            lastSavedBrowsingAddress = urlAddress
                            loadURL()
                        }
                        .onChange(of: webStore.actualUrl) { oldValue, newValue in
                            urlAddress = newValue
                        }
                    Divider()
                        .padding(.vertical, 2)
                }

                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .disabled(!canGoBack)
                
                Button(action: goForward) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .disabled(!canGoForward)
                
                Button(action: {
                    
                    if (geminiAPIKey.lengthOfBytes(using: .utf8) < 3) {
                        alertMsg = "Sorry, please config your Gemini-API Key."
                        alertShowing.toggle()
                        return
                    }
                    
                    let theUrl = urlAddress
                    if (!theUrl.starts(with: "https://leetcode.com/problems/")) {
                        alertMsg = "Sorry, the URL not supported!"
                        alertShowing.toggle()
                        return
                    }
                    
                    showProcessingView = true
                    
                    Task {
                        processor = Processor(geminiAIKey: geminiAPIKey, store: ChallengeStore(context: self.modelContext))
                        
                        do {
                            try await processor!.proceed(theUrl)
                        } catch {
                            alertMsg = "Sorry, something went wrong"
                            alertShowing = true
                        }
                        
                        showProcessingView = false
                    }
                    
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

            }
            .padding(10)
            .background(Color.hex(0xFAFBFC))
            
            ZStack(alignment: .top) {
                
                WebViewRepresentable(
                    webView: webStore.webView,
                    urlAddress: $urlAddress,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    loadingProgress: $loadingProgress
                )
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .offset(x:0, y:1)
                .onAppear {
                    canGoBack = webStore.webView.canGoBack
                    canGoForward = webStore.webView.canGoForward
                }
                
                if loadingProgress > 0 {
                    ProgressView(value: loadingProgress)
                        .progressViewStyle(.linear)
                        .scaleEffect(x: 1, y: 0.3, anchor: .top)
                        .tint(.blue)
                        .opacity(loadingProgress > 0 ? 1 : 0)
                        .animation(.easeOut(duration: 0.3), value: (loadingProgress > 0.1))
                }
                
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        .background(.white)
    }
    
    //MARK: PRIVATE
    private func loadURL(){
        let _urlAddress = urlAddress;
        
        var urlString = _urlAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        if !urlString.contains("://") {
            if urlString.contains(".") {
                urlString = "https://" + urlString
            } else {
                urlString = "https://www.google.com/search?q=" + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            }
        }
        
        guard let url = URL(string: urlString) else { return }
        webStore.webView.load(URLRequest(url: url))
    }
    
    func goBack() {
        webStore.webView.goBack()
    }
    
    func goForward() {
        webStore.webView.goForward()
    }
        
    struct WebViewRepresentable: NSViewRepresentable {
                
        var webView: WKWebView

        @Binding var urlAddress: String;
        @Binding var canGoBack: Bool;
        @Binding var canGoForward: Bool;
        @Binding var loadingProgress: Double;
        
        func makeNSView(context: Context) -> WKWebView {
            
            webView.navigationDelegate = context.coordinator
            webView.uiDelegate = context.coordinator
            webView.allowsBackForwardNavigationGestures = true
            
            return webView            
        }
                        
        func updateNSView(_ webView: WKWebView, context: Context) {
            // WebView updates handled by coordinator
        }
        
        func makeCoordinator() -> Coordinator {
            
            let coordinator = Coordinator(self)
            
            coordinator.progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { _, change in
                
                DispatchQueue.main.async {
                    let val = change.newValue ?? 0
                    coordinator.parent.loadingProgress = val > 0.9 ? 0 : val
                    
                    coordinator.parent.canGoBack = webView.canGoBack
                    coordinator.parent.canGoForward = webView.canGoForward
                }
                
            }
            
            return coordinator
        }
        
        class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
            
            let parent: WebViewRepresentable
            var progressObservation: NSKeyValueObservation?
            
            init(_ parent: WebViewRepresentable) {
                self.parent = parent
            }
             
            //MARK: WKUIDelegate
            func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
                if let url = navigationAction.request.url {
                    self.parent.webView.load(URLRequest(url: url))
                }
                return nil // important
            }
            
            //MARK: WKNavigationDelegate
            func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
                if let url = webView.url?.absoluteString {
                    parent.urlAddress = url
                    parent.loadingProgress = 0.1
                }
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                self.parent.loadingProgress = 0
            }
            
            func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                self.parent.loadingProgress = 0
            }
            
        }
    }
}

@MainActor
final class ChallengeStore: SaveToChallengeDB {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func saveOrUpdate(_ item: ChallengeItem) async throws {

        // Fetch by primary key (id)
        let challegeId = item.challegeId
        
        let descriptor = FetchDescriptor<ChallengeItem>(
            predicate: #Predicate<ChallengeItem> { $0.challegeId == challegeId },
            sortBy: []
        )

        let existing = try context.fetch(descriptor).first

        if let existing {
            // UPDATE
            existing.title = item.title
            existing.url = item.url
            existing.src = item.src
            existing.timestamp = item.timestamp
        } else {
            // INSERT
            context.insert(item)
        }

        try context.save()
    }
}
