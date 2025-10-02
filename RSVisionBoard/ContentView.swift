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
        NavigationSplitView {
            VStack {
                Text("Vision Board")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Create and organize your vision board")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
                
                Text("Items: \(viewModel.items.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
        } detail: {
            VisionBoardCanvas(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
