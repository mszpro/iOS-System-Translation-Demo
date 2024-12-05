//
//  PopupTranslation.swift
//  iOSTranslationVideo
//
//  Created by msz on 2024/12/01.
//

import SwiftUI

#if canImport(Translation)
import Translation
#endif

struct PopupTranslation: View {
    
    @State private var sourceText = "Hello, World!"
    @State private var targetText = ""
    
    @State private var isTranslationShown: Bool = false
    
    var body: some View {
        
        NavigationStack {
            Form {
                
                Section {
                    Label("Source text", systemImage: "globe")
                    
                    TextField("What do you want to translate?",
                              text: $sourceText,
                              axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                }
                
                Section {
                    Label("Translated text", systemImage: "globe")
                    
                    Text(targetText)
                }
                
            }
            .navigationTitle("Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Translate") {
                        self.isTranslationShown = true
                    }
                }
            }
#if canImport(Translation)
            .translationPresentation(isPresented: $isTranslationShown,
                                     text: self.sourceText)
            { newString in
                self.targetText = newString
            }
#endif
        }
        
    }
    
}

#Preview {
    PopupTranslation()
}
