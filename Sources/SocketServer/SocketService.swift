import ServiceLifecycle

final class SocketService {
	let numberOfThreads: Int?
	let socketPath: String
	
	init(socketPath: String, numberOfThreads: Int? = nil) {
		self.socketPath = socketPath
		self.numberOfThreads = numberOfThreads
	}
	
	func run() async throws {		
		let eventLoop = EventLoop(socketPath: socketPath, numberOfThreads: numberOfThreads)
		
		var configuration = ServiceGroupConfiguration(service: eventLoop, logger: Logging.logger)
		configuration.cancellationSignals = [.sigint, .sigterm]
		
		let serviceGroup = ServiceGroup(configuration: configuration)
		try await serviceGroup.run()
	}
}
