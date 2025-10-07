# RSVisionBoard

An iOS and macOS SwiftUI application for designing personal vision boards. Combine inspirational photos, decorative elements, and custom text on a free-form canvas, enhance imagery with adjustable effects, and export your creations with one tap.

## Features

- **Drag-and-drop canvas** – Position, resize, and rotate text or image items with intuitive gestures.
- **Rich image pipeline** – Apply vintage, noir, blur, brightness, and other Core Image powered effects, including subject lifting with transparent backgrounds.
- **Element picker** – Drop pre-made stickers and accents from the bundled asset library.
- **Typography tools** – Add editable text boxes using the stylized Zapfino font.
- **Vision overlay** – Start every board with a centered inspirational hero image that you can build around.
- **Share anywhere** – Capture the full canvas as a high-resolution snapshot and share it via the native iOS share sheet.

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-org>/RSVisionBoard.git
   cd RSVisionBoard
   ```
2. **Open the project**
   - Launch `RSVisionBoard.xcodeproj` in Xcode 15 or later.
3. **Select a target**
   - Choose the `RSVisionBoard` scheme and an iOS 17 simulator/device (or the macOS destination).
4. **Run**
   - Press `⌘R` to build and launch the app.

## Usage Tips

- Tap **Add Image** to pull from the photo library, then tweak the selection using the built-in effects modal before placing it on the board.
- Use **Add Elements** to decorate with bundled stickers such as tape or stars.
- Tap a text box to edit its content; drag its edges to reposition, rotate with two fingers, or pinch to scale images.
- Press the floating **Share** button (iOS) to export a flattened snapshot that preserves all applied filters and transparency.

## Architecture

- **SwiftUI Views** – `ContentView` hosts the canvas, toolbars, and share workflow; `VisionBoardCanvas` renders board items and manages gestures.
- **ViewModel** – `VisionBoardViewModel` stores `VisionBoardItem` models, handles default assets, and mutates item geometry.
- **Models** – `VisionBoardItem` describes the content type, layout, and transformation state for each board element.
- **Image Effects** – `ImageEffectsModal` composes Core Image filters with Vision subject masks to offer live previews and final exports.

## Customization

- Add new default stickers by dropping assets into `Assets.xcassets` and listing them in `ElementsPickerView`.
- Extend `ImageEffect` and `BackgroundEffect` enums to introduce additional filters or background presets.
- Adjust the initial scaling/position of items in `VisionBoardViewModel` to tailor the default layout to your needs.

## Roadmap Ideas

- Persistence for saving and loading multiple boards.
- Undo/redo stack for safer editing.
- Cloud sync and cross-device sharing.
- Widget or Live Activity support for quick inspiration.

## Contributing

1. Fork the repository and create a feature branch.
2. Follow the existing SwiftUI patterns (MVVM with Combine) and match the styling conventions.
3. Open a pull request with a concise summary of your changes.

## License

This project includes sample assets for demonstration. Replace them with your own imagery before distributing the app. See the repository’s LICENSE file for complete details.
