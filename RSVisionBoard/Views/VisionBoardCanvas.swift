//
//  VisionBoardCanvas.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 29/09/25.
//

import SwiftUI
import Combine

#if os(iOS)
import UIKit
#else
import AppKit
import UniformTypeIdentifiers
#endif

struct VisionBoardCanvas: View {
    @ObservedObject var viewModel: VisionBoardViewModel
    @State private var draggedItem: VisionBoardItem?
    @State private var showingImagePicker = false
    @State private var selectedItemForImage: VisionBoardItem?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                backgroundView
                GridPatternView()
                itemsContent
            }
        }
#if os(iOS)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedItem: $selectedItemForImage, viewModel: viewModel)
        }
#else
        .alert("Select Image", isPresented: $showingImagePicker) {
            Button("Cancel") { showingImagePicker = false }
            Button("Choose") {
                selectImageFromFilePicker()
            }
        } message: {
            Text("Select an image file to add to your vision board")
        }
#endif
    }
    
    private var backgroundView: some View {
        Color.white
            .edgesIgnoringSafeArea(.all)
    }
    
    private var itemsContent: some View {
        ForEach(viewModel.items) { item in
            itemView(item)
        }
    }
    
    private func itemView(_ item: VisionBoardItem) -> some View {
        let itemCenter = CGPoint(
            x: item.position.width + item.size.width / 2,
            y: item.position.height + item.size.height / 2
        )
        
        return VisionBoardItemView(
            item: item,
            viewModel: viewModel,
            showingImagePicker: $showingImagePicker,
            selectedItemForImage: $selectedItemForImage
        )
        .position(itemCenter)
        .gesture(
            DragGesture()
                .onChanged { value in
                    draggedItem = item
                    viewModel.moveItem(item, to: CGSize(
                        width: value.startLocation.x + value.translation.width - item.size.width / 2,
                        height: value.startLocation.y + value.translation.height - item.size.height / 2
                    ))
                }
                .onEnded { _ in
                    draggedItem = nil
                }
        )
    }

#if os(macOS)
    private func selectImageFromFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                if let imageData = try? Data(contentsOf: url),
                   let nsImage = NSImage(data: imageData) {
                    if let selectedItem = selectedItemForImage {
                        if let index = viewModel.items.firstIndex(where: { $0.id == selectedItem.id }) {
                            let resizedImage = nsImage.resized(to: CGSize(width: 300, height: 300))
                            viewModel.items[index].imageData = resizedImage.pngData()
                        }
                    }
                }
            }
        }
        showingImagePicker = false
    }
#endif
}

struct VisionBoardItemView: View {
    let item: VisionBoardItem
    let viewModel: VisionBoardViewModel
    @Binding var showingImagePicker: Bool
    @Binding var selectedItemForImage: VisionBoardItem?
    @State private var isEditing: Bool = false
    @State private var tempText: String = ""
    
    var body: some View {
        textOrImageContent
            .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
    }
    
    @ViewBuilder
    private var textOrImageContent: some View {
        if item.type == .text {
            textContentView
        } else {
            imageContentView
        }
    }
    
    private var textContentView: some View {
        Group {
            if isEditing {
                textFieldView
            } else {
                textView
            }
        }
    }
    
    private var textFieldView: some View {
        TextField("", text: $tempText, onCommit: {
            if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                viewModel.items[index].text = tempText
            }
            isEditing = false
        })
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .frame(width: item.size.width, height: item.size.height)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var textView: some View {
        Text(item.text)
            .frame(width: item.size.width, height: item.size.height)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture {
                tempText = item.text
                isEditing = true
            }
    }
    
    private var imageContentView: some View {
        Group {
            if item.imageData != nil {
                imageView
            } else {
                placeholderView
            }
        }
    }
    
#if os(iOS)
    private var imageView: some View {
        if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: item.size.width, height: item.size.height)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        return AnyView(EmptyView())
    }
#else
    private var imageView: some View {
        if let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
            return AnyView(
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: item.size.width, height: item.size.height)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        return AnyView(EmptyView())
    }
#endif
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: item.size.width, height: item.size.height)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .font(.title2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture {
                selectedItemForImage = item
                showingImagePicker = true
            }
    }
}

struct GridPatternView: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 50
            let gridColor = Color.gray.opacity(0.1)
            
            // Vertical lines
            for x in stride(from: 0, through: size.width, by: step) {
                context.stroke(
                    Path(CGRect(x: x, y: 0, width: 0.5, height: size.height)),
                    with: .color(gridColor),
                    lineWidth: 0.5
                )
            }
            
            // Horizontal lines
            for y in stride(from: 0, through: size.height, by: step) {
                context.stroke(
                    Path(CGRect(x: 0, y: y, width: size.width, height: 0.5)),
                    with: .color(gridColor),
                    lineWidth: 0.5
                )
            }
        }
    }
}

#if os(iOS)
// Image Picker View
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedItem: VisionBoardItem?
    let viewModel: VisionBoardViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(selectedItem: Binding<VisionBoardItem?>, viewModel: VisionBoardViewModel) {
        _selectedItem = selectedItem
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                // Update the selected item with the image data
                if let selectedItem = parent.selectedItem {
                    if let index = parent.viewModel.items.firstIndex(where: { $0.id == selectedItem.id }) {
                        let resizedImage = uiImage.resized(to: CGSize(width: 300, height: 300))
                        parent.viewModel.items[index].imageData = resizedImage.pngData()
                        print("Image data set: \(parent.viewModel.items[index].imageData != nil)")
                    }
                }
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#if os(iOS)
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
#endif
#else
extension NSImage {
    func resized(to size: CGSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        let rect = NSRect(origin: .zero, size: size)
        self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
    
    func pngData() -> Data? {
        guard let tiffData = tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let data = bitmapRep.representation(using: .png, properties: [:]) else {
            return nil
        }
        return data
    }
}
#endif
