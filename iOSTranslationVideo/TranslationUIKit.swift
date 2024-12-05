//
//  TranslationUIKit.swift
//  iOSTranslationVideo
//
//  Created by msz on 2024/12/05.
//

import Foundation
import UIKit
import SwiftUI

#if canImport(Translation)
import Translation
#endif

struct EmbeddedTranslationView: View {
    var sourceText: String
    @State private var isTranslationShown: Bool = false
    
    var body: some View {
        VStack {
#if canImport(Translation)
            Button("Translate") {
                self.isTranslationShown = true
            }
            .translationPresentation(isPresented: $isTranslationShown,
                                     text: self.sourceText)
#else
            Text("Translation feature not available.")
#endif
        }
    }
}

// UIKit ViewController
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Create the SwiftUI view
        let embeddedSwiftUIView = EmbeddedTranslationView(sourceText: "Hello world! This is a test.")
        
        // Embed the SwiftUI view in a UIHostingController
        let hostingController = UIHostingController(rootView: embeddedSwiftUIView)
        
        // Add the UIHostingController as a child view controller
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Layout the SwiftUI view
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            hostingController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }
}

// Wrap UIKit ViewController for SwiftUI
struct UIKitViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates required for now
    }
}

// Add a SwiftUI Preview for Testing
struct UIKitViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewWrapper()
            .edgesIgnoringSafeArea(.all)
    }
}
