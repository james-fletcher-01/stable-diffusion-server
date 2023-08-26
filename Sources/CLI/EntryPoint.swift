import Foundation
import ArgumentParser

@main
struct EntryPoint: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: ProcessInfo.processInfo.processName,
		abstract: "Starts a socket server that can be used to generate images using CoreML Stable Diffusion.",
		discussion: """
			The socket accepts a JSON string containing an object with the following keys:
				- prompt: Input string prompt
				- negative-prompt: Input string negative prompt
				- image: Path to starting image (optional).
				- image-count: Number of images to sample / generate. Defaults to 1.
				- save-every: How often to save samples at intermediate steps. Set to 0 to only save the final sample. Defaults to 0.
			If the input can't be parsed as a JSON string, it is assumed to be a plain string containing only a prompt.\n
			The response is a JSON string containing an array for each generated image, with each element consisting of an array of image names for each sample image, which can be found in the output path. The last element in each array is the final generated image.
		""",
		version: "1.0.0"
	)
	
	@OptionGroup(title: "Socket Options")
	var socketOptions: SocketOptions
	
	@OptionGroup(title: "Image Generation Options")
	var imageGenerationOptions: ImageGenerationOptions
	
    mutating func run() async throws {
		try initializeImageGenerationConfiguration()
		let server = initializeSocketServer()
		
		try await server.run()
    }
	
	private func initializeImageGenerationConfiguration() throws {
		do {
			try ImageGenerationConfiguration.configure(options: imageGenerationOptions)
		} catch let error as ImageGenerationError {
			Logging.logger.error("\(error.errorString)")
		}
	}
	
	private func initializeSocketServer() -> SocketService {
		let socketPath = socketOptions.socketPath.standardizedFileURLString
		return SocketService(socketPath: socketPath, numberOfThreads: socketOptions.numberOfThreads)
	}
}
