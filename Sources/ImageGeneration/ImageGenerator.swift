import StableDiffusion
import CoreGraphics
import CoreImage
import UniformTypeIdentifiers
import Logging

final class ImageGenerator {
	typealias RunError = ImageGenerationError
	
	let requestID: String
	let configuration: ImageConfiguration
	let logger: Logger
	
	private var images = ImageList()
	
	init(requestID: String, configuration: ImageConfiguration, logger: Logger) {
		self.requestID = requestID
		self.configuration = configuration
		self.logger = logger
	}
	
	func generate() throws -> String {
		let startingImage = try configuration.getStartingImage()
		let pipelineConfig = getPipelineConfiguration(startingImage: startingImage)
		try generateImages(pipelineConfig: pipelineConfig)
		
		return images.getJSON()
	}
	
	private func generateImages(pipelineConfig: StableDiffusionPipeline.Configuration) throws {
		logger.debug("Sampling...")
		let sampleTimer = SampleTimer()
		sampleTimer.start()
		
		let images = try ImageGenerationConfiguration.pipeline!.generateImages(
			configuration: pipelineConfig,
			progressHandler: { progress in
				sampleTimer.stop()
				handleProgress(progress, sampleTimer)
				if progress.stepCount != progress.step {
					sampleTimer.start()
				}
				return true
			}
		)
		
		try saveImages(images, logNames: true)
	}
	
	private func getPipelineConfiguration(startingImage: CGImage?) -> StableDiffusionPipeline.Configuration {
		var pipelineConfig = ImageGenerationConfiguration.pipelineConfig!
		
		pipelineConfig.prompt = configuration.prompt
		pipelineConfig.negativePrompt = configuration.negativePrompt
		pipelineConfig.startingImage = startingImage
		pipelineConfig.imageCount = configuration.imageCount
		
		return pipelineConfig
	}
	
	private func handleProgress(_ progress: StableDiffusionPipeline.Progress, _ sampleTimer: SampleTimer) {
		let mean = String(format: "%.2f", 1.0/sampleTimer.mean)
		let median = String(format: "%.2f", 1.0/sampleTimer.median)
		let last = String(format: "%.2f", 1.0/sampleTimer.allSamples.last!)
		var logLine = "Step \(progress.step) of \(progress.stepCount) [mean: \(mean), median: \(median), last \(last)] step/sec"
		
		if configuration.saveEvery > 0, progress.step % configuration.saveEvery == 0 {
			let saveCount = (try? saveImages(progress.currentImages, step: progress.step)) ?? 0
			logLine += " saved \(saveCount) image\(saveCount != 1 ? "s" : "")"
		}
		
		logger.trace("\(logLine)")
	}
	
	@discardableResult
	private func saveImages(_ images: [CGImage?], step: Int? = nil, logNames: Bool = false) throws -> Int {
		let url = ImageGenerationConfiguration.outputPath!
		var saved = 0
		for i in 0 ..< images.count {
			guard let image = images[i] else {
				if logNames {
					logger.notice("Image \(i) failed safety check and was not saved")
				}
				continue
			}
			
			let name = imageName(i, step: step)
			let fileURL = url.appending(path:name)
			
			guard let dest = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
				throw RunError.saving("Failed to create destination for \(fileURL)")
			}
			CGImageDestinationAddImage(dest, image, nil)
			if !CGImageDestinationFinalize(dest) {
				throw RunError.saving("Failed to save \(fileURL)")
			}
			if logNames {
				logger.trace("Saved \(name)")
			}
			
			self.images[i].append(name)
			saved += 1
		}
		return saved
	}
	
	private func imageName(_ sample: Int, step: Int? = nil) -> String {
		var name = requestID
		if configuration.imageCount != 1 {
			name += ".\(sample)"
		}
		
		if let step = step {
			name += ".\(step)"
		} else {
			name += ".final"
		}
		
		name += ".png"
		return name
	}
}
