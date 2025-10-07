//
//  ContentView.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 29/09/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @StateObject private var viewModel = VisionBoardViewModel()
    @State private var showingImagePicker = false
    @State private var showingElementsPicker = false
#if os(iOS)
    @State private var shareImage: UIImage?
    @State private var showingShareSheet = false
#endif
    
    var body: some View {
        NavigationView {
            ZStack {
                VisionBoardCanvas(viewModel: viewModel, showingImagePicker: $showingImagePicker)
                
#if os(iOS)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        shareButton
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 24)
                }
#endif
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
                        showingImagePicker = true
                    }) {
                        Label("Add Image", systemImage: "photo.badge.plus")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingElementsPicker = true
                    }) {
                        Label("Add Elements", systemImage: "square.grid.2x2")
                    }
                }
            }
            .sheet(isPresented: $showingElementsPicker) {
                ElementsPickerView(viewModel: viewModel)
            }
        }
#if os(iOS)
        .sheet(isPresented: $showingShareSheet) {
            if let shareImage {
                ShareSheet(activityItems: [shareImage])
            }
        }
#endif
    }

#if os(iOS)
    private var shareButton: some View {
        Button(action: prepareShareImage) {
            Image(systemName: "square.and.arrow.up")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.blue)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Share Vision Board")
    }

    private func prepareShareImage() {
        let renderer = ImageRenderer(
            content: VisionBoardCanvas(
                viewModel: viewModel,
                showingImagePicker: .constant(false)
            )
        )
        renderer.scale = UIScreen.main.scale
        if let rendered = renderer.uiImage {
            shareImage = rendered
            showingShareSheet = true
        }
    }
#endif
}

#Preview {
    ContentView()
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
