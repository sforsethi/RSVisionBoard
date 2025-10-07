//
//  ContentView.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 29/09/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = VisionBoardViewModel()
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            VisionBoardCanvas(viewModel: viewModel, showingImagePicker: $showingImagePicker)
                .navigationTitle("Vision Board")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            viewModel.addTextItem()
                        }) {
                            Label("Add Text", systemImage: "text.badge.plus")
                        }
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Label("Add Image", systemImage: "photo.badge.plus")
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
