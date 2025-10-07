//
//  ElementsPickerView.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 07/10/25.
//

import SwiftUI

struct ElementsPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VisionBoardViewModel
    
    // List of available asset names
    private let availableAssets = ["tape", "star", "vision"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(availableAssets, id: \.self) { assetName in
                        ElementAssetCard(assetName: assetName) {
                            addElementToBoard(assetName: assetName)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Add Elements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addElementToBoard(assetName: String) {
        print("🎨 Adding element: \(assetName)")
        
        if let image = UIImage(named: assetName) {
            print("✅ Loaded asset image: \(assetName)")
            
            let imageData = image.pngData()
            let originalSize = image.size
            
            // Scale to appropriate size for elements
            let scaledSize = CGSize(
                width: originalSize.width * 0.15,
                height: originalSize.height * 0.15
            )
            
            let newItem = VisionBoardItem(
                type: .image,
                text: "",
                imageData: imageData,
                position: CGSize(width: 150, height: 150), // Default position
                size: scaledSize,
                scale: 1.0
            )
            
            // Add the item directly to the view model
            viewModel.items.append(newItem)
            print("✅ Added element to vision board: \(newItem.id)")
        } else {
            print("❌ Could not load asset image: \(assetName)")
        }
        
        dismiss()
    }
}

struct ElementAssetCard: View {
    let assetName: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if let image = UIImage(named: assetName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            Text(assetName)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ElementsPickerView(viewModel: VisionBoardViewModel())
}
