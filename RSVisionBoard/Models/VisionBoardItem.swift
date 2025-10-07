//
//  VisionBoardItem.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 29/09/25.
//

import Foundation
import CoreGraphics

enum VisionBoardItemType: String, CaseIterable {
    case text = "Text"
    case image = "Image"
}

struct VisionBoardItem: Identifiable, Hashable {
    let id = UUID()
    var type: VisionBoardItemType
    var text: String = ""
    var imageData: Data? = nil
    var position: CGSize = .zero
    var size: CGSize = CGSize(width: 200, height: 100)
    var scale: CGFloat = 1.0
    var rotation: Double = 0.0 // Rotation in degrees
}