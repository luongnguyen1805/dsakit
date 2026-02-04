//
//  Processor.swift
//  DSAKit
//
//  Created by admin on 1/28/26.
//

import Foundation
import SwiftSoup
import ZIPFoundation

protocol SaveToChallengeDB {
    func saveOrUpdate(_ item: ChallengeItem) async throws
}

actor Processor {
    
    //MARK: NESTED
    struct ProblemInfo {
        let source: String      // "leetcode", "codeforces", "hackerrank", "unknown"
        let id: String          // "94", "A-1234", etc.
        let title: String
        let description: String
    }
    
    //MARK: PROPS
    let geminiAPIKey: String
    let store: SaveToChallengeDB
    
    //MARK: INIT
    init(geminiAIKey: String, store: SaveToChallengeDB) {
        self.geminiAPIKey = geminiAIKey
        self.store = store
    }
    
    //MARK: MAIN
    func proceed(url: String, pseusoCode: String = "") async throws {
        
        //Get page content
        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
                
        //Detect {page-id, description}
        let problemInfo = parseForInfo(url: url, src: String(data: data, encoding: .utf8)!)
        
        let setupCode = try await generateSetupCode(problem: problemInfo, pseudoCode: pseusoCode)
        
        let workspaceDir = try await setupWorkspace(problem: problemInfo, setupCode: setupCode)
        
        let item = ChallengeItem(
            challegeId: problemInfo.id,
            title: problemInfo.title,
            url: url,
            src: workspaceDir,
            timestamp: Date()
        )

        try await store.saveOrUpdate(item)
    }
    
    //MARK: Private
    func openInVSCode(_ folder: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", "Visual Studio Code", folder.path]
        try process.run()
    }

    func setupWorkspace(problem: ProblemInfo, setupCode: String) async throws -> String {

        guard let zipPath = Bundle.main.path(forResource: "Swift", ofType: "zip") else {
            throw NSError(domain: "TemplateZipMissing", code: 1)
        }

        let fileManager = FileManager.default
        
        let documentDir = URL(fileURLWithPath: NSString(string:"~/Documents").expandingTildeInPath)
        
        let containerDir = documentDir.appendingPathComponent("DSAKit")
        if fileManager.fileExists(atPath: containerDir.path) == false {
            try fileManager.createDirectory(at: containerDir, withIntermediateDirectories: true)
        }
        
        let workspaceDir = containerDir.appendingPathComponent("\(problem.source)-\(problem.id)")
        
        // 3. Create target directory
        if fileManager.fileExists(atPath: workspaceDir.path) {
            try fileManager.removeItem(at: workspaceDir)
        }

        // 4. Extract template archive
        let zipURL = URL(fileURLWithPath: zipPath)
        
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        try fileManager.unzipItem(
            at: zipURL,
            to: tempDir
        )
        
        let extractedRoot = tempDir.appendingPathComponent("Swift")
        try fileManager.moveItem(
            at: extractedRoot,
            to: workspaceDir
        )

        // 5. Replace Source/Global.swift
        let targetFile = workspaceDir
            .appendingPathComponent("Source")
            .appendingPathComponent("Global.swift")

        if fileManager.fileExists(atPath: targetFile.path) {
            try fileManager.removeItem(at: targetFile)
        }
            
        try setupCode.write(
            to: targetFile,
            atomically: true,
            encoding: .utf8
        )
        
        try openInVSCode(workspaceDir)
        
        return workspaceDir.path
    }

    private func generateSetupCode(problem: ProblemInfo, pseudoCode: String = "") async throws -> String {
        
        struct GeminiRequest: Codable {
            struct Content: Codable {
                struct Part: Codable {
                    let text: String
                }
                let role: String? // Optional for single turn
                let parts: [Part]
            }
            let contents: [Content]
            let generationConfig: GenerationConfig?
            
            struct GenerationConfig: Codable {
                let temperature: Double
            }
        }

        struct GeminiResponse: Codable {
            struct Candidate: Codable {
                struct Content: Codable {
                    struct Part: Codable {
                        let text: String
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }

        let geminiKey = "\(self.geminiAPIKey)" // Ensure this is your Gemini key
        let modelName = "gemini-2.5-flash" // or "gemini-1.5-pro"

        guard let url = Bundle.main.url(forResource: "Prompt", withExtension: "md") else {
            throw NSError(domain: "PromptMissing", code: 1)
        }
        let promptTemplate = try String(contentsOf: url, encoding: .utf8)

        let userPrompt = promptTemplate
            .replacingOccurrences(of: "{{PROBLEM_TITLE}}", with: problem.title)
            .replacingOccurrences(of: "{{PROBLEM_SOURCE}}", with: problem.source)
            .replacingOccurrences(of: "{{PROBLEM_DESCRIPTION}}", with: problem.description)
            .replacingOccurrences(of: "{{PSEUDO_CODE}}", with: pseudoCode)

        //TEST
//        let documentDir = URL(fileURLWithPath: NSString(string:"~/Documents").expandingTildeInPath)
//        let logFile = documentDir.appendingPathComponent("dsakit.log")
//        try FileManager.default.removeItem(at: logFile)
//        try userPrompt.write(to: logFile, atomically: true, encoding: .utf8)
        //END TEST
        
        // Gemini doesn't have a "system" role in the same way;
        // you usually prepend instructions to the user prompt or use 'system_instruction' field.
        let requestBody = GeminiRequest(
            contents: [
                GeminiRequest.Content(
                    role: "user",
                    parts: [GeminiRequest.Content.Part(text: userPrompt)]
                )
            ],
            generationConfig: GeminiRequest.GenerationConfig(temperature: 0.2)
        )

        let urlString = "https://generativelanguage.googleapis.com/v1/models/\(modelName):generateContent?key=\(geminiKey)"
        guard let apiUrl = URL(string: urlString) else {
            throw NSError(domain: "InvalidURL", code: 2)
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        return response.candidates.first?.content.parts.first?.text ?? ""
    }

    private func parseForInfo(url: String, src: String) -> ProblemInfo {
        
        var problemSource = ""
        
        let lower = url.lowercased()
        if lower.contains("leetcode.com") {
            problemSource = "leetCode"
        } else if lower.contains("codeforces.com") {
            problemSource = "codeforces"
        } else if lower.contains("hackerrank.com") {
            problemSource = "hackerrank"
        }
        
        let (problemId, problemTitle, problemDesc) = getIdAndDescriptionLeetcode(src: src)
        
        return ProblemInfo(source: problemSource, id: problemId, title: problemTitle, description: problemDesc)
    }
    
    private func getIdAndDescriptionLeetcode(
        src: String
    ) -> (String, String, String) {

        do {
            let doc = try SwiftSoup.parse(src)

            // 1. Extract __NEXT_DATA__ JSON
            guard
                let jsonText = try doc
                    .select("script#__NEXT_DATA__")
                    .first()?
                    .html(),
                let jsonData = jsonText.data(using: .utf8),
                let root = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            else {
                return ("", "", "")
            }

            // 2. Navigate step-by-step (important for Swift)
            guard
                let props = root["props"] as? [String: Any],
                let pageProps = props["pageProps"] as? [String: Any],
                let dehydratedState = pageProps["dehydratedState"] as? [String: Any],
                let queries = dehydratedState["queries"] as? [[String: Any]]
            else {
                return ("", "", "")
            }

            // 3. Find question object
            let question: [String: Any]? = queries
                .compactMap { query in
                    guard
                        let state = query["state"] as? [String: Any],
                        let data = state["data"] as? [String: Any],
                        let question = data["question"] as? [String: Any]
                    else {
                        return nil
                    }
                    return question
                }
                .first

            guard let q = question else {
                return ("", "", "")
            }

            // 4. Extract fields
            let id = q["questionId"] as? String ?? ""
            let title = q["title"] as? String ?? ""
            let contentHTML = q["content"] as? String ?? ""

            // 5. HTML → text
            let description = try SwiftSoup.parse(contentHTML).text()

            return (id, title, description)

        } catch {
            return ("", "", "")
        }
    }
    
    private func getIdAndDescriptionCodeforce(src: String) -> (String, String) {
        return ("", "")

    }

    private func getIdAndDescriptionHackerrank(src: String) -> (String, String) {
        return ("", "")
    }

}
