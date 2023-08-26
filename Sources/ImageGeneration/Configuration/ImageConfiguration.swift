import Foundation
import CoreGraphics

struct ImageConfiguration {
	private(set) var prompt: String
	private(set) var negativePrompt: String = ""
	
	private(set) var image: URL? = nil
	
	private(set) var imageCount: Int = 1
	private(set) var saveEvery: Int = 0
	
	func getStartingImage() throws -> CGImage? {
		guard let imageURL = image else {
			return nil
		}
		
		do {
			return try InputImageConverter.convertImageToCGImage(imageURL: imageURL)
		} catch let error {
			throw ImageGenerationError.resources("Starting image not found \(imageURL), error: \(error)")
		}
	}
	
	static func makeConfiguration(_ string: String) -> Self {
		let data = Data(string.utf8)
		
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		
		do {
			return try decoder.decode(self, from: data)
		} catch {
			return Self(prompt: string)
		}
	}
}

extension ImageConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case prompt = "prompt"
		case negativePrompt = "negative-prompt"
		case image = "image"
		case imageCount = "image-count"
		case saveEvery = "save-every"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		prompt = try container.decode(String.self, forKey: .prompt)
		
		let negativePrompt = try container.decodeIfPresent(String.self, forKey: .negativePrompt)
		if let negativePrompt {
			self.negativePrompt = negativePrompt
		}
		
		let imageCount = try container.decodeIfPresent(Int.self, forKey: .imageCount)
		if let imageCount {
			self.imageCount = imageCount
		}
		
		let saveEvery = try container.decodeIfPresent(Int.self, forKey: .saveEvery)
		if let saveEvery {
			self.saveEvery = saveEvery
		}
		
		let imagePath = try container.decodeIfPresent(String.self, forKey: .image)
		if let imagePath {
			image = URL(fileURLWithPath: imagePath)
		}
	}
}
