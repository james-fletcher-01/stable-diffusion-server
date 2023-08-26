import Foundation
import AppKit
import CoreGraphics

enum InputImageConverter {
	static func convertImageToCGImage(imageURL: URL) throws -> CGImage {
		guard
			let imageData = try? Data(contentsOf: imageURL),
			let nsImage = NSImage(data: imageData),
			let loadedImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
		else {
			throw ImageGenerationError.resources("Image not available \(imageURL)")
		}
		return loadedImage
	}
}
