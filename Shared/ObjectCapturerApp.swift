//
//  ObjectCapturerApp.swift
//  Shared
//
//  Created by Bill Haku on 2021/10/29.
//  Copyright © 2021 Apple. All rights reserved.
//

import SwiftUI
import Foundation
import AppKit

@main
struct ObjectCapturerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelecate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
