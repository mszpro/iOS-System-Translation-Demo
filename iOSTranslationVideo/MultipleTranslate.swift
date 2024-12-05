//
//  MultipleTranslate.swift
//  iOSTranslationVideo
//
//  Created by msz on 2024/12/05.
//

import SwiftUI
import Translation

struct MultipleTranslate: View {
    
    // translation struct with the original text and optional translated text String
    struct TranslationEntry: Identifiable {
        let id: String
        let originalText: String
        var translatedText: String?
        
        init(id: String = UUID().uuidString, originalText: String, translatedText: String? = nil) {
            self.id = id
            self.originalText = originalText
            self.translatedText = translatedText
        }
    }
    
    @State private var textsToTranslate: [TranslationEntry] = [
        .init(originalText: "Hello world! This is just a test."),
        .init(originalText: "The quick brown fox jumps over the lazy dog."),
        .init(originalText: "How are you doing today?"),
        .init(originalText: "It is darkest just before the dawn."),
        .init(originalText: "The early bird catches the worm."),
    ]
    @State private var userEnteredNewText: String = ""
    
    @State private var configuration: TranslationSession.Configuration?
    
    var body: some View {
        
        Form {
            
            // list all text
            Section("Texts to translate") {
                List {
                    ForEach(textsToTranslate) { text in
                        VStack(alignment: .leading) {
                            // original text
                            Text(text.originalText)
                                .font(.headline)
                            // translated text, if available
                            if let translatedText = text.translatedText {
                                Text(translatedText)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            
            // allow user to add a new text, using a TextField and a Button
            Section("Add new text") {
                HStack {
                    TextField("Enter text to translate",
                              text: $userEnteredNewText)
                    Button("Add") {
                        textsToTranslate.append(.init(originalText: userEnteredNewText))
                        userEnteredNewText = ""
                    }
                }
            }
            
            Button("Translate all to Japanese") {
                self.configuration = .init(target: .init(identifier: "ja"))
            }
            
        }
        .translationTask(configuration) { session in
            let allRequests = textsToTranslate.map {
                return TranslationSession.Request(
                    sourceText: $0.originalText,
                    clientIdentifier: $0.id)
            }
            do {
                for try await response in session.translate(batch: allRequests) {
                    print(response.targetText, response.clientIdentifier ?? "")
                    if let i = self.textsToTranslate.firstIndex(where: { $0.id == response.clientIdentifier }) {
                        var entry = self.textsToTranslate[i]
                        entry.translatedText = response.targetText
                        self.textsToTranslate.remove(at: i)
                        self.textsToTranslate.insert(entry, at: i)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
}

#Preview {
    MultipleTranslate()
}
