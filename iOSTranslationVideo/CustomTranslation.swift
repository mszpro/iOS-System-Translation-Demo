//
//  CustomTranslation.swift
//  iOSTranslationVideo
//
//  Created by msz on 2024/12/01.
//

import SwiftUI
import Translation

struct CustomTranslation: View {
    
    @State private var textToTranslate: String?
    @State private var translationConfiguration: TranslationSession.Configuration?
    @State private var translationResult: String?
    
    var body: some View {
        Form {
            
            Section("Original text") {
                if let textToTranslate {
                    Text(textToTranslate)
                }
            }
            
            Section("Translated text") {
                if let translationResult {
                    Text(translationResult)
                }
            }
            
        }
        .translationTask(translationConfiguration) { session in
            do {
                guard let textToTranslate else { return }
                let response = try await session.translate(textToTranslate)
                self.translationResult = response.targetText
            } catch {
                print("Error: \(error)")
            }
        }
        .task {
            // fetch the text
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: "https://raw.githubusercontent.com/swiftlang/swift/refs/heads/main/.github/ISSUE_TEMPLATE/task.yml")!)
                guard let webPageContent = String(data: data, encoding: .utf8) else { return }
                // start a translation to Japanese
                self.textToTranslate = webPageContent
                self.translationConfiguration = .init(target: .init(identifier: "ja"))
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
}

#Preview {
    CustomTranslation()
}




