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
    
    @Published var sourceFilter: String = ""
    @Published var targetFilter: String = ""
    
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
    @State private var buttonTapped = false
    
    var configuration: TranslationSession.Configuration {
        TranslationSession.Configuration(
            source: viewModel.sourceLanguage,
            target: viewModel.targetLanguage
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Source Language Section
                Section(header: Text("Source Language")) {
                    TextField("Filter languages", text: $viewModel.sourceFilter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    .onChange(of: viewModel.sourceLanguage) { _, _ in
                        Task {
                            await viewModel.checkLanguageSupport()
                        }
                    }
                }
                
                // Target Language Section
                Section(header: Text("Target Language")) {
                    TextField("Filter languages", text: $viewModel.targetFilter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 4)
                    
                    Picker("Select Target Language", selection: $viewModel.targetLanguage) {
                        ForEach(viewModel.filteredTargetLanguages, id: \.maximalIdentifier) { language in
                            Button {} label: {
                                Text(viewModel.displayName(for: language))
                                Text(language.minimalIdentifier)
                            }
                            .tag(language)
                        }
                    }
                    .onChange(of: viewModel.targetLanguage) { _, _ in
                        Task {
                            await viewModel.checkLanguageSupport()
                        }
                    }
                }
                
                // Status Section
                Section {
                    HStack {
                        Spacer()
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
                        Spacer()
                    }
                }
                
                // Download Button Section
                if viewModel.languageStatus == .supported {
                    Section {
                        Button(action: {
                            buttonTapped = true
                        }) {
                            Text("Download Translation")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Language Selector")
            .onAppear {
                Task {
                    await viewModel.checkLanguageSupport()
                }
            }
            .translationTask(configuration) { session in
                if buttonTapped {
                    do {
                        // Display a sheet asking the user's permission to start downloading the language pairing.
                        try await session.prepareTranslation()
                        // Update the language status after downloading
                        await viewModel.checkLanguageSupport()
                        buttonTapped = false
                    } catch {
                        // Handle any errors.
                        print("Error downloading translation: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    LanguageAvailabilityChecker()
}
