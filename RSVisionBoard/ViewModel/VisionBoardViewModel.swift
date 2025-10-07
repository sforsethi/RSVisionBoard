//
//  VisionBoardViewModel.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 29/09/25.
//

import Foundation
import SwiftUI
import Combine

#if os(iOS)
import UIKit
import Photos
#endif

@MainActor
class VisionBoardViewModel: ObservableObject {
    @Published var items: [VisionBoardItem] = []
    @Published var shouldShowImagePicker = false
    
    init() {
        addDefaultVisionImage()
    }
    
    #if os(iOS)
    func addDefaultVisionImage() {
        if let image = UIImage(named: "vision") {
            print("✅ Loaded default vision image from Assets")
            let imageData = image.pngData()
            let originalSize = image.size
            
            // Scale to 30% of original for a nice default size
            let scaledSize = CGSize(
                width: originalSize.width * 0.3,
                height: originalSize.height * 0.3
            )
            
            // Calculate center position (adjusting for screen size)
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let centerPosition = CGSize(
                width: (screenWidth - scaledSize.width) / 2,
                height: (screenHeight - scaledSize.height - 200) / 2 // 200 is roughly the nav bar + toolbar height
            )
            
            let defaultItem = VisionBoardItem(
                type: .image,
                text: "",
                imageData: imageData,
                position: centerPosition,
                size: scaledSize,
                scale: 1.0
            )
            
            // Insert at beginning to ensure it's rendered first (before other items)
            items.insert(defaultItem, at: 0)
            print("✅ Added default vision image to center of board")
        } else {
            print("❌ Could not load 'vision' image from Assets")
        }
    }
    #else
    func addDefaultVisionImage() {
        // For macOS, use a default center position
        let defaultSize = CGSize(width: 200, height: 200)
        let centerPosition = CGSize(width: 300, height: 200)
        
        let defaultItem = VisionBoardItem(
            type: .image,
            text: "Vision",
            imageData: nil,
            position: centerPosition,
            size: defaultSize,
            scale: 1.0
        )
        
        items.append(defaultItem)
        print("✅ Added default placeholder for macOS")
    }
    #endif
    
    func updateItem(_ item: VisionBoardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func addTextItem() {
        let newItem = VisionBoardItem(type: .text, text: "New Text Box")
        items.append(newItem)
    }
    
    #if os(iOS)
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        print("📸 Photo library authorization status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("✅ Photo library access authorized")
            shouldShowImagePicker = true
        case .denied, .restricted:
            print("❌ Photo library access denied")
        case .notDetermined:
            print("📸 Requesting photo library access")
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        print("✅ Photo library access granted")
                        self.shouldShowImagePicker = true
                    } else {
                        print("❌ Photo library access denied")
                    }
                }
            }
        case .limited:
            print("✅ Limited photo library access")
            shouldShowImagePicker = true
        @unknown default:
            print("❓ Unknown photo library status")
        }
    }
#else
    func checkPhotoLibraryPermission() {
        shouldShowImagePicker = true
    }
#endif
    
    func addImageItem() {
        // This will be handled by the view
    }
    
    func addImageItem(with imageData: Data, size: CGSize) {
        print("📸 addImageItem(with:) called - creating new item")
        print("📸 Image data size: \(imageData.count) bytes")
        print("📸 Item size: \(size)")
        
        let newItem = VisionBoardItem(
            type: .image,
            text: "",
            imageData: imageData,
            position: CGSize(width: 100, height: 100), // Default position
            size: size,
            scale: 1.0
        )
        
        items.append(newItem)
        print("✅ Added new image item with ID: \(newItem.id)")
        print("✅ Total items now: \(items.count)")
        print("✅ Items array: \(items.map { "\($0.id): \($0.type)" })")
        
        // Reset the flag
        shouldShowImagePicker = false
        print("📸 Reset shouldShowImagePicker to false")
    }
    
    func moveItem(_ item: VisionBoardItem, to position: CGSize) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].position = position
        }
    }
    
    func resizeItem(_ item: VisionBoardItem, to size: CGSize) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].size = size
        }
    }
    
    func scaleItem(_ item: VisionBoardItem, by scale: CGFloat) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].scale = scale
        }
    }
    
    func rotateItem(_ item: VisionBoardItem, to rotation: Double) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].rotation = rotation
        }
    }
}