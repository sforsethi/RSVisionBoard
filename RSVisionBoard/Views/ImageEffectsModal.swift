//
//  ImageEffectsModal.swift
//  RSVisionBoard
//
//  Created by Raghav Sethi on 07/10/25.
//

import SwiftUI

#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct ImageEffectsModal: View {
    let originalImage: UIImage
    @Binding var isPresented: Bool
    @State private var selectedEffect: ImageEffect = .none
    @State private var intensity: Double = 0.5
    @Environment(\.dismiss) private var dismiss
    let onImageEdited: (UIImage) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Preview area
                imagePreview
                    .frame(height: 300)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(12)
                
                // Effects grid
                effectsGrid
                
                // Intensity slider
                if selectedEffect != .none {
                    intensitySlider
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        applyEffectAndDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var imagePreview: some View {
        Image(uiImage: applyEffect(to: originalImage))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8)
    }
    
    private var effectsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            ForEach(ImageEffect.allCases, id: \.self) { effect in
                EffectButton(
                    effect: effect,
                    isSelected: selectedEffect == effect,
                    originalImage: originalImage
                ) {
                    selectedEffect = effect
                }
            }
        }
    }
    
    private var intensitySlider: some View {
        VStack(alignment: .leading) {
            Text("Intensity")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Slider(value: $intensity, in: 0...1)
                .accentColor(.blue)
        }
    }
    
    private func applyEffect(to image: UIImage) -> UIImage {
        switch selectedEffect {
        case .none:
            return image
        case .vintage:
            return applyVintageEffect(to: image, intensity: intensity)
        case .blur:
            return applyBlurEffect(to: image, intensity: intensity)
        case .blackAndWhite:
            return applyBlackAndWhiteEffect(to: image, intensity: intensity)
        case .sepia:
            return applySepiaEffect(to: image, intensity: intensity)
        case .vignette:
            return applyVignetteEffect(to: image, intensity: intensity)
        case .brightness:
            return applyBrightnessEffect(to: image, intensity: intensity)
        case .contrast:
            return applyContrastEffect(to: image, intensity: intensity)
        case .saturate:
            return applySaturateEffect(to: image, intensity: intensity)
        }
    }
    
    private func applyEffectAndDismiss() {
        let editedImage = applyEffect(to: originalImage)
        onImageEdited(editedImage)
        dismiss()
    }
}

struct EffectButton: View {
    let effect: ImageEffect
    let isSelected: Bool
    let originalImage: UIImage
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Image(uiImage: applyPreviewEffect())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 3)
                }
            }
            
            Text(effect.displayName)
                .font(.caption2)
                .foregroundColor(.primary)
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private func applyPreviewEffect() -> UIImage {
        switch effect {
        case .none:
            return originalImage
        case .vintage:
            return applyVintageEffect(to: originalImage, intensity: 0.7)
        case .blur:
            return applyBlurEffect(to: originalImage, intensity: 0.3)
        case .blackAndWhite:
            return applyBlackAndWhiteEffect(to: originalImage, intensity: 1.0)
        case .sepia:
            return applySepiaEffect(to: originalImage, intensity: 0.7)
        case .vignette:
            return applyVignetteEffect(to: originalImage, intensity: 0.7)
        case .brightness:
            return applyBrightnessEffect(to: originalImage, intensity: 0.5)
        case .contrast:
            return applyContrastEffect(to: originalImage, intensity: 0.5)
        case .saturate:
            return applySaturateEffect(to: originalImage, intensity: 0.5)
        }
    }
}

enum ImageEffect: CaseIterable {
    case none
    case vintage
    case blur
    case blackAndWhite
    case sepia
    case vignette
    case brightness
    case contrast
    case saturate
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .vintage: return "Vintage"
        case .blur: return "Blur"
        case .blackAndWhite: return "B&W"
        case .sepia: return "Sepia"
        case .vignette: return "Vignette"
        case .brightness: return "Bright"
        case .contrast: return "Contrast"
        case .saturate: return "Saturate"
        }
    }
}

// MARK: - Image Effect Functions
#if os(iOS)
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

func applyVintageEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    
    // Apply sepia tone
    let sepiaFilter = CIFilter.sepiaTone()
    sepiaFilter.inputImage = ciImage
    sepiaFilter.intensity = Float(intensity * 0.8)
    guard let sepiaOutput = sepiaFilter.outputImage else { return image }
    
    // Add noise for vintage effect
    let noiseFilter = CIFilter.photoEffectNoir()
    noiseFilter.inputImage = ciImage
    guard let noiseOutput = noiseFilter.outputImage else { return image }
    
    // Blend with original
    let blendFilter = CIFilter.screenBlendMode()
    blendFilter.inputImage = sepiaOutput
    blendFilter.backgroundImage = noiseOutput
    guard let blendedOutput = blendFilter.outputImage else { return image }
    
    // Adjust opacity
    let opacityFilter = CIFilter.sourceOverCompositing()
    opacityFilter.inputImage = blendedOutput
    opacityFilter.backgroundImage = ciImage
    
    guard let finalOutput = opacityFilter.outputImage,
          let cgImage = context.createCGImage(finalOutput, from: ciImage.extent) else {
        return image
    }
    
    return UIImage(cgImage: cgImage)
}

func applyBlurEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    let blurFilter = CIFilter.gaussianBlur()
    blurFilter.inputImage = ciImage
    blurFilter.radius = Float(intensity * 20)
    
    guard let output = blurFilter.outputImage,
          let cgImage = context.createCGImage(output, from: ciImage.extent) else {
        return image
    }
    
    return UIImage(cgImage: cgImage)
}

func applyBlackAndWhiteEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    let monoFilter = CIFilter.photoEffectNoir()
    monoFilter.inputImage = ciImage
    
    guard let output = monoFilter.outputImage,
          let cgImage = context.createCGImage(output, from: ciImage.extent) else {
        return image
    }
    
    // Blend with original based on intensity
    if intensity < 1.0 {
        return blendImages(original: image, filtered: UIImage(cgImage: cgImage), intensity: intensity)
    }
    
    return UIImage(cgImage: cgImage)
}

func applySepiaEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    let sepiaFilter = CIFilter.sepiaTone()
    sepiaFilter.inputImage = ciImage
    sepiaFilter.intensity = Float(intensity)
    
    guard let output = sepiaFilter.outputImage,
          let cgImage = context.createCGImage(output, from: ciImage.extent) else {
        return image
    }
    
    return UIImage(cgImage: cgImage)
}

func applyVignetteEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    let vignetteFilter = CIFilter.vignette()
    vignetteFilter.inputImage = ciImage
    vignetteFilter.intensity = Float(intensity)
    vignetteFilter.radius = Float(min(ciImage.extent.width, ciImage.extent.height) * 0.7)
    
    guard let output = vignetteFilter.outputImage,
          let cgImage = context.createCGImage(output, from: ciImage.extent) else {
        return image
    }
    
    return UIImage(cgImage: cgImage)
}

func applyBrightnessEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    let colorControlsFilter = CIFilter.colorControls()
    colorControlsFilter.inputImage = ciImage
    colorControlsFilter.brightness = Float((intensity - 0.5) * 2)
    
    guard let output = colorControlsFilter.outputImage,
          let cgImage = context.createCGImage(output, from: ciImage.extent) else {
        return image
    }
    
    return UIImage(cgImage: cgImage)
}

func applyContrastEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    let colorControlsFilter = CIFilter.colorControls()
    colorControlsFilter.inputImage = ciImage
    colorControlsFilter.contrast = Float(intensity * 2)
    
    guard let output = colorControlsFilter.outputImage,
          let cgImage = context.createCGImage(output, from: ciImage.extent) else {
        return image
    }
    
    return UIImage(cgImage: cgImage)
}

func applySaturateEffect(to image: UIImage, intensity: Double) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    
    let context = CIContext()
    let colorControlsFilter = CIFilter.colorControls()
    colorControlsFilter.inputImage = ciImage
    colorControlsFilter.saturation = Float(intensity * 2)
    
    guard let output = colorControlsFilter.outputImage,
          let cgImage = context.createCGImage(output, from: ciImage.extent) else {
        return image
    }
    
    return UIImage(cgImage: cgImage)
}

func blendImages(original: UIImage, filtered: UIImage, intensity: Double) -> UIImage {
    guard let originalData = original.pngData(),
          let filteredData = filtered.pngData() else {
        return original
    }
    
    // Simple overlay blend - in a production app, you'd use proper Core Image blending
    return intensity > 0.5 ? filtered : original
}

#else
// macOS placeholder implementations
func applyVintageEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func applyBlurEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func applyBlackAndWhiteEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func applySepiaEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func applyVignetteEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func applyBrightnessEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func applyContrastEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func applySaturateEffect(to image: UIImage, intensity: Double) -> UIImage { return image }
func blendImages(original: UIImage, filtered: UIImage, intensity: Double) -> UIImage { return original }
#endif