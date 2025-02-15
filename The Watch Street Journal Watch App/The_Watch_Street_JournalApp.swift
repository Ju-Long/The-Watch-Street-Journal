//
//  The_Watch_Street_JournalApp.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 18/6/23.
//

import SwiftUI

@main
struct The_Watch_Street_Journal_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView() 
                .environment(\.managedObjectContext, persistenceController.managedObjectContext)
//            TestContentView()
        }
    }
}

class AppDelegate: NSObject, WKApplicationDelegate {
    
}
