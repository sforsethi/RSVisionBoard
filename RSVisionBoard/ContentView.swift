//
//  ContentView.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 29/09/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = VisionBoardViewModel()
    
    var body: some View {
        NavigationView {
            VisionBoardCanvas(viewModel: viewModel)
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
                            viewModel.addImageItem()
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
