import Foundation
import CoreML
import StableDiffusion

enum ImageGenerationConfiguration {
	typealias RunError = ImageGenerationError
	
	private(set) static var pipeline: StableDiffusionPipelineProtocol?
	private(set) static var pipelineConfig: StableDiffusionPipeline.Configuration?
	private(set) static var outputPath: URL?
	
	static func configure(options: ImageGenerationOptions) throws {
		let resourcePath = options.resourcePath.standardizedFileURLString
		guard FileManager.default.fileExists(atPath: resourcePath) else {
			throw RunError.resources("Resource path does not exist \(resourcePath)")
		}
		
		let outptPath = options.outputPath.standardizedFileURLString
		guard FileManager.default.fileExists(atPath: outptPath) else {
			throw RunError.resources("Output path does not exist \(outptPath)")
		}
		
		let config = MLModelConfiguration()
		config.computeUnits = options.computeUnits.asMLComputeUnits
		
		do {
			Logging.logger.debug("Loading resources and creating pipeline")
			pipeline = try makePipeline(options: options, resourceURL: options.resourcePath, config: config)
		} catch {
			throw RunError.resources("Error Loading Resources: \(error)")
		}
		
		let controlNetInputs = try getControlNetInputs(options: options)
		pipelineConfig = makePipelineConfiguration(options: options, controlNetInputs: controlNetInputs)
		
		outputPath = options.outputPath
	}
	
	private static func makePipeline(options: ImageGenerationOptions, resourceURL: URL, config: MLModelConfiguration) throws -> StableDiffusionPipelineProtocol {
		let pipeline: StableDiffusionPipelineProtocol
		if #available(macOS 14.0, *) {
			if options.isXL {
				if !options.controlnet.isEmpty {
					throw RunError.unsupported("ControlNet is not supported for Stable Diffusion XL")
				}
				if options.useMultilingualTextEncoder {
					throw RunError.unsupported("Multilingual text encoder is not yet supported for Stable Diffusion XL")
				}
				pipeline = try StableDiffusionXLPipeline(
					resourcesAt: resourceURL,
					configuration: config,
					reduceMemory: options.reduceMemory
				)
			} else {
				pipeline = try StableDiffusionPipeline(
					resourcesAt: resourceURL,
					controlNet: options.controlnet,
					configuration: config,
					disableSafety: options.disableSafety,
					reduceMemory: options.reduceMemory,
					useMultilingualTextEncoder: options.useMultilingualTextEncoder,
					script: options.script
				)
			}
		} else  {
			pipeline = try StableDiffusionPipeline(
				resourcesAt: resourceURL,
				controlNet: options.controlnet,
				configuration: config,
				disableSafety: options.disableSafety,
				reduceMemory: options.reduceMemory
			)
		}
		
		try pipeline.loadResources()
		return pipeline
	}
	
	private static func makePipelineConfiguration(options: ImageGenerationOptions, controlNetInputs: [CGImage]) -> StableDiffusionPipeline.Configuration {
		var pipelineConfig = StableDiffusionPipeline.Configuration(prompt: "")
		
		pipelineConfig.strength = options.strength
		pipelineConfig.stepCount = options.stepCount
		pipelineConfig.seed = options.seed
		pipelineConfig.controlNetInputs = controlNetInputs
		pipelineConfig.guidanceScale = options.guidanceScale
		pipelineConfig.schedulerType = options.scheduler.stableDiffusionScheduler
		pipelineConfig.rngType = options.rng.stableDiffusionRNG
		
		if options.isXL {
			pipelineConfig.encoderScaleFactor = 0.13025
			pipelineConfig.decoderScaleFactor = 0.13025
		}
		
		return pipelineConfig
	}
	
	private static func getControlNetInputs(options: ImageGenerationOptions) throws -> [CGImage] {
		let controlNetInputs: [CGImage]
		if !options.controlnet.isEmpty {
			controlNetInputs = try options.controlnetInputs.map { imagePath in
				let imageURL = URL(filePath: imagePath)
				do {
					return try InputImageConverter.convertImageToCGImage(imageURL: imageURL)
				} catch let error {
					throw RunError.resources("Image for ControlNet not found \(imageURL), error: \(error)")
				}
			}
		} else {
			controlNetInputs = []
		}
		
		return controlNetInputs
	}
}
