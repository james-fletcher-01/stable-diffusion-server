import Foundation
import ArgumentParser
import StableDiffusion

struct ImageGenerationOptions: ParsableArguments {
	@Option(
		name: .shortAndLong,
		help: ArgumentHelp(
			"Path to stable diffusion resources.",
			discussion: """
				The resource directory should contain
				- *compiled* models: {TextEncoder,Unet,VAEDecoder}.mlmodelc
				- tokenizer info: vocab.json, merges.txt
			"""
		)
	)
	var resourcePath: URL
	
	@Option(name: .shortAndLong, help: "Output path")
	var outputPath: URL
	
	@Flag(name: .customLong("xl"), help: "The resources correspond to a Stable Diffusion XL model")
	var isXL: Bool = false
	
	@Option(help: "Strength for image2image.")
	var strength: Float = 0.5
	
	@Option(help: "Number of diffusion steps to perform")
	var stepCount: Int = 50
	
	@Option(help: "Random seed")
	var seed: UInt32 = UInt32.random(in: 0...UInt32.max)
	
	@Option(help: "Controls the influence of the text prompt on sampling process (0=random images)")
	var guidanceScale: Float = 7.5
	
	@Option(help: "Compute units to load model with {all,cpuOnly,cpuAndGPU,cpuAndNeuralEngine}")
	var computeUnits: ComputeUnits = .all
	
	@Option(help: "Scheduler to use, one of {pndm, dpmpp}")
	var scheduler: SchedulerOption = .pndm
	
	@Option(help: "Random number generator to use, one of {numpy, torch}")
	var rng: RNGOption = .numpy
	
	@Option(
		parsing: .upToNextOption,
		help: "ControlNet models used in image generation (enter file names in Resources/controlnet without extension)"
	)
	var controlnet: [String] = []
	
	@Option(
		parsing: .upToNextOption,
		help: "image for each controlNet model (corresponding to the same order as --controlnet)"
	)
	var controlnetInputs: [String] = []
	
	@Flag(help: "Disable safety checking")
	var disableSafety: Bool = false
	
	@Flag(help: "Reduce memory usage")
	var reduceMemory: Bool = false
	
	@Flag(help: "Use system multilingual NLContextualEmbedding as encoder model")
	var useMultilingualTextEncoder: Bool = false
	
	@Option(help: "The natural language script for the multilingual contextual embedding")
	var script: Script = .latin
}



