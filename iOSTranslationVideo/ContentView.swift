//
//  ContentView.swift
//  iOSTranslationVideo
//
//  Created by msz on 2024/12/01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            
            List {
                
                NavigationLink("Popup translation dialog") {
                    PopupTranslation()
                }
                
                NavigationLink("Translation API") {
                    CustomTranslation()
                }
                
                NavigationLink("Language availability checker") {
                    LanguageAvailabilityChecker()
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    VStack(alignment: .leading) {
                        Text("iOS Translation API")
                            .font(.title3)
                            .bold()
                            .monospaced()
                        
                        Text("Tutorial By @MszPro https://mszpro.com")
                    }
                }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
