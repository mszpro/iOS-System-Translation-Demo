//
//  LanguageAvailabilityChecker.swift
//  iOSTranslationVideo
//
//  Created by msz on 2024/12/01.
//

import SwiftUI
import Translation

fileprivate class ViewModel: ObservableObject {
    @Published var sourceLanguage: Locale.Language = Locale.current.language
    @Published var targetLanguage: Locale.Language = Locale.current.language
    
    @Published var languageStatus: LanguageAvailability.Status = .unsupported
    
    @Published var sourceFilter: String = "English"
    @Published var targetFilter: String = "German"
    
    let languages: [Locale.Language]
    
    init() {
        // Initialize the list of available languages
        let languageCodes = Locale.LanguageCode.isoLanguageCodes
        self.languages = languageCodes.compactMap { Locale.Language(languageCode: $0) }
    }
    
    func displayName(for language: Locale.Language) -> String {
        guard let languageCode = language.languageCode?.identifier else {
            return language.maximalIdentifier
        }
        return Locale.current.localizedString(forLanguageCode: languageCode) ?? languageCode
    }
    
    var filteredSourceLanguages: [Locale.Language] {
        if sourceFilter.isEmpty {
            return languages
        } else {
            return languages.filter {
                displayName(for: $0).localizedCaseInsensitiveContains(sourceFilter)
            }
        }
    }
    
    var filteredTargetLanguages: [Locale.Language] {
        if targetFilter.isEmpty {
            return languages
        } else {
            return languages.filter {
                displayName(for: $0).localizedCaseInsensitiveContains(targetFilter)
            }
        }
    }
    
    func checkLanguageSupport() async {
        let availability = LanguageAvailability()
        let status = await availability.status(from: sourceLanguage, to: targetLanguage)
        
        DispatchQueue.main.async {
            self.languageStatus = status
        }
    }
}


struct LanguageAvailabilityChecker: View {
    @StateObject fileprivate var viewModel = ViewModel()
    
    var body: some View {
        Form {
            // Source Language Section
            Section("Source Language") {
                TextField("Filter languages", text: $viewModel.sourceFilter)
                    .padding(.vertical, 4)
                
                Picker("Select Source Language", selection: $viewModel.sourceLanguage) {
                    ForEach(viewModel.filteredSourceLanguages, id: \.maximalIdentifier) { language in
                        Button {} label: {
                            Text(viewModel.displayName(for: language))
                            Text(language.minimalIdentifier)
                        }
                        .tag(language)
                    }
                }
                .disabled(viewModel.filteredSourceLanguages.isEmpty)
                .onChange(of: viewModel.sourceLanguage) { _, _ in
                    Task {
                        await viewModel.checkLanguageSupport()
                    }
                }
            }
            
            // Target Language Section
            Section("Target Language") {
                TextField("Filter languages", text: $viewModel.targetFilter)
                
                Picker("Select Target Language", selection: $viewModel.targetLanguage) {
                    ForEach(viewModel.filteredTargetLanguages, id: \.maximalIdentifier) { language in
                        Button {} label: {
                            Text(viewModel.displayName(for: language))
                            Text(language.minimalIdentifier)
                        }
                        .tag(language)
                    }
                }
                .disabled(viewModel.filteredTargetLanguages.isEmpty)
                .onChange(of: viewModel.targetLanguage) { _, _ in
                    Task {
                        await viewModel.checkLanguageSupport()
                    }
                }
            }
            
            // Status Section
            Section {
                if viewModel.languageStatus == .installed {
                    Text("✅ Translation Installed")
                        .foregroundColor(.green)
                } else if viewModel.languageStatus == .supported {
                    Text("⬇️ Translation Available to Download")
                        .foregroundColor(.orange)
                } else {
                    Text("❌ Translation Not Supported")
                        .foregroundColor(.red)
                }
            }
            
            // Download Button Section
            if viewModel.languageStatus == .supported {
                NavigationLink("Download") {
                    TranslationModelDownloader(sourceLanguage: viewModel.sourceLanguage,
                                               targetLanguage: viewModel.targetLanguage)
                }
            }
        }
        .navigationTitle("Language Selector")
        .onAppear {
            Task {
                await viewModel.checkLanguageSupport()
            }
        }
    }
}

#Preview {
    LanguageAvailabilityChecker()
}

struct TranslationModelDownloader: View {
    
    var configuration: TranslationSession.Configuration
    
    init(sourceLanguage: Locale.Language, targetLanguage: Locale.Language) {
        self.configuration = TranslationSession.Configuration(source: sourceLanguage, target: targetLanguage)
    }
    
    var body: some View {
        NavigationView {
            Text("Download translation files between \(configuration.source?.minimalIdentifier ?? "?") and \(configuration.target?.minimalIdentifier ?? "?")")
            .translationTask(configuration) { session in
                do {
                    try await session.prepareTranslation()
                } catch {
                    // Handle any errors.
                    print("Error downloading translation: \(error)")
                }
            }
        }
    }
}
