//
//  RSVisionBoardApp.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 29/09/25.
//

import SwiftUI

#if os(iOS)
import Photos
#endif

@main
struct RSVisionBoardApp: App {
    
    init() {
        // Request photo library permission at app launch
        #if os(iOS)
        DispatchQueue.main.async {
            PHPhotoLibrary.requestAuthorization { status in
                print("📸 Initial photo library permission status: \(status.rawValue)")
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
