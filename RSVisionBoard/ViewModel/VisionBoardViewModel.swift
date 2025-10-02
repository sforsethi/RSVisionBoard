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
#endif

@MainActor
class VisionBoardViewModel: ObservableObject {
    @Published var items: [VisionBoardItem] = []
    
    func addTextItem() {
        let newItem = VisionBoardItem(type: .text, text: "New Text Box")
        items.append(newItem)
    }
    
    func addImageItem() {
        // For now, create a placeholder image item
        // In a real app, this would trigger image picker
        let newItem = VisionBoardItem(type: .image)
        items.append(newItem)
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
}