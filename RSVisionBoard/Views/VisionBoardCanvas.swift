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
import PhotosUI
import Photos
#else
import AppKit
import UniformTypeIdentifiers
#endif

struct VisionBoardCanvas: View {
    @ObservedObject var viewModel: VisionBoardViewModel
    @State private var draggedItem: VisionBoardItem?
    @Binding var showingImagePicker: Bool
    @State private var inputImage: UIImage?
    @State private var showingImageEffects = false
    @State private var selectedImageForEffects: UIImage?
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
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
            ImagePicker(image: $inputImage)
        }
#else
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerMac(image: $inputImage)
        }
#endif
        .onChange(of: inputImage) { image in
            if let image = image {
                print("📸 Image selected: \(image.size)")
                selectedImageForEffects = image
                showingImageEffects = true
                inputImage = nil
            }
        }
        .sheet(isPresented: $showingImageEffects) {
            if let image = selectedImageForEffects {
                ImageEffectsModal(
                    originalImage: image,
                    isPresented: $showingImageEffects
                ) { editedImage in
                    // Add the edited image to vision board
                    addImageToVisionBoard(editedImage)
                }
            }
        }
    }
    
    private func addImageToVisionBoard(_ image: UIImage) {
        print("📸 Adding edited image to vision board: \(image.size)")
        
        // Create a new vision board item with the image
        let imageData = image.pngData()!
        let originalSize = image.size
        let scaledSize = CGSize(width: originalSize.width * 0.1, height: originalSize.height * 0.1)
        
        let newItem = VisionBoardItem(
            type: .image,
            text: "",
            imageData: imageData,
            position: CGSize(width: 100, height: 100),
            size: scaledSize,
            scale: 1.0
        )
        
        viewModel.items.append(newItem)
        print("✅ Added edited image to vision board")
        selectedImageForEffects = nil
    }
    
    private var backgroundView: some View {
        Color.white
            .edgesIgnoringSafeArea(.all)
    }
    
    private var itemsContent: some View {
        // Separate vision image (first item if it has imageData) and other items
        let visionItem = viewModel.items.first { $0.imageData != nil && $0.type == .image }
        let otherItems = viewModel.items.filter { $0.id != visionItem?.id }
        
        return ZStack {
            // Render other items first
            ForEach(otherItems) { item in
                itemView(item)
            }
            
            // Always render vision image on top
            if let visionItem = visionItem {
                itemView(visionItem)
                    .zIndex(999) // Ensure it's always on top
            }
        }
    }
    
    private func itemView(_ item: VisionBoardItem) -> some View {
        let basePosition = CGPoint(
            x: item.position.width + item.size.width / 2,
            y: item.position.height + item.size.height / 2
        )
        
        // Check if this is the default vision image (first image with data)
        let isVisionImage = item.id == viewModel.items.first(where: { $0.imageData != nil })?.id
        
        // Apply drag offset if this is the item being dragged (but not vision image)
        let currentPosition: CGPoint
        if isDragging && draggedItem?.id == item.id && !isVisionImage {
            currentPosition = CGPoint(
                x: basePosition.x + dragOffset.width,
                y: basePosition.y + dragOffset.height
            )
        } else {
            currentPosition = basePosition
        }
        
        return VisionBoardItemView(
            item: item,
            viewModel: viewModel,
            isVisionImage: isVisionImage
        )
        .position(currentPosition)
        .id(item.id) // Force view refresh when item changes
        .allowsHitTesting(!isVisionImage) // Disable hit testing for vision image
        .gesture(
            // Only add drag gesture if it's not the vision image
            !isVisionImage ? DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        draggedItem = item
                    }
                    dragOffset = value.translation
                }
                .onEnded { value in
                    // Update the actual position in the viewModel
                    let newPosition = CGSize(
                        width: item.position.width + value.translation.width,
                        height: item.position.height + value.translation.height
                    )
                    viewModel.moveItem(item, to: newPosition)
                    
                    // Reset drag state
                    isDragging = false
                    draggedItem = nil
                    dragOffset = .zero
                }
            : nil
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPosition)
    }
}

struct VisionBoardItemView: View {
    let item: VisionBoardItem
    let viewModel: VisionBoardViewModel
    let isVisionImage: Bool
    @State private var isEditing: Bool = false
    @State private var tempText: String = ""
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Double = 0.0
    
    var body: some View {
        textOrImageContent
            .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
            .id(item.imageData == nil ? "\(item.id)-empty" : "\(item.id)-filled")
            .scaleEffect(item.type == .image ? currentScale : 1.0)
            .rotationEffect(.degrees(currentRotation))
            .gesture(
                // Only add gestures if it's not the vision image
                !isVisionImage ? 
                // Combine rotation and scale gestures
                SimultaneousGesture(
                    // Rotation gesture for all items (except vision image)
                    RotationGesture()
                        .onChanged { angle in
                            currentRotation = angle.degrees
                        }
                        .onEnded { _ in
                            viewModel.rotateItem(item, to: currentRotation)
                        },
                    // Scale gesture only for images
                    item.type == .image ? 
                    MagnificationGesture()
                        .onChanged { value in
                            currentScale = value
                        }
                        .onEnded { _ in
                            viewModel.scaleItem(item, by: currentScale)
                        }
                    : nil
                )
                : nil
            )
            .onAppear {
                currentScale = item.scale
                currentRotation = item.rotation
                print("🎨 VisionBoardItemView appeared for item: \(item.id), type: \(item.type), hasImage: \(item.imageData != nil)")
            }
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
        .font(.custom("Zapfino", size: 16))
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .frame(width: item.size.width, height: item.size.height)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var textView: some View {
        Text(item.text)
            .font(.custom("Zapfino", size: 16))
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
                Color.clear
            }
        }
    }
    
#if os(iOS)
    private var imageView: some View {
        Group {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: item.size.width, height: item.size.height)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onAppear {
                        print("🎨 Rendering image for item \(item.id): size=\(uiImage.size)")
                    }
            } else {
                Color.clear
                    .onAppear {
                        print("❌ Could not render image for item \(item.id): imageData=\(item.imageData != nil)")
                    }
            }
        }
    }
#else
    private var imageView: some View {
        Group {
            if let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: item.size.width, height: item.size.height)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Color.clear
            }
        }
    }
#endif
    
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
// Simple Image Picker View
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
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

// macOS Image Picker
struct ImagePickerMac: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @State private var selectedFile: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select an Image")
                .font(.title)
            
            Text("Choose an image file to add to your vision board")
                .foregroundColor(.secondary)
            
            Button("Browse...") {
                selectImageFromFile()
            }
            .buttonStyle(.borderedProminent)
            
            if selectedFile != nil {
                Text("Selected: \(selectedFile?.lastPathComponent ?? "")")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Button("Choose") {
                    if let url = selectedFile {
                        loadImage(from: url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedFile == nil)
            }
        }
        .padding(30)
        .frame(width: 400, height: 250)
    }
    
    private func selectImageFromFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        
        if panel.runModal() == .OK {
            selectedFile = panel.url
        }
    }
    
    private func loadImage(from url: URL) {
        print("📁 Loading image from: \(url)")
        
        if let imageData = try? Data(contentsOf: url),
           let nsImage = NSImage(data: imageData) {
            print("✅ Image loaded: \(nsImage.size)")
            
            // Convert NSImage to UIImage for consistency
            if let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let uiImage = UIImage(cgImage: cgImage)
                image = uiImage
                print("✅ Set image")
            }
        }
        
        isPresented = false
    }
}
#endif
