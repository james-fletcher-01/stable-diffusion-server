import ServiceLifecycle
import NIO

final class EventLoop: Service {
	let numberOfThreads: Int
	let socketPath: String
	
	init(socketPath: String, numberOfThreads: Int? = nil) {
		self.socketPath = socketPath
		self.numberOfThreads = numberOfThreads ?? System.coreCount
	}
	
	func run() async throws {
		let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
		
		defer {
			try! eventLoopGroup.syncShutdownGracefully()
		}
		
		guard let channel = await bindChannel(eventLoopGroup: eventLoopGroup) else {
			return
		}
		
		Logging.logger.info("Server started and listening on \(channel.localAddress!)")
		
		try await waitForChannel(channel)
		Logging.logger.info("Server stopped")
	}
	
	private func bindChannel(eventLoopGroup: EventLoopGroup) async -> Channel? {
		let channel: Channel
		
		do {
			let bootstrap = createBootstrap(group: eventLoopGroup)
			channel = try await bootstrap.bind(unixDomainSocketPath: socketPath).get()
		} catch {
			Logging.logger.error("Error binding to socket: \(error)")
			return nil
		}
		
		return channel
	}
	
	private func waitForChannel(_ channel: Channel) async throws {
		try await withTaskCancellationHandler {
			try await channel.closeFuture.get()
		} onCancel: {
			channel.close(promise: nil)
		}
	}
	
	private func createBootstrap(group eventLoopGroup: some EventLoopGroup) -> ServerBootstrap {
		return ServerBootstrap(group: eventLoopGroup)
			.serverChannelOption(
				ChannelOptions.backlog,
				value: 256
			)
			.serverChannelOption(
				ChannelOptions.socketOption(.so_reuseaddr),
				value: 1
			)
			.childChannelInitializer { channel in
				channel.pipeline.addHandlers([
					BackPressureHandler(),
					ChannelHandler()
				])
			}
			.childChannelOption(
				ChannelOptions.socketOption(.so_reuseaddr),
				value: 1
			)
			.childChannelOption(
				ChannelOptions.maxMessagesPerRead,
				value: 16
			)
			.childChannelOption(
				ChannelOptions.recvAllocator,
				value: AdaptiveRecvByteBufferAllocator()
			)
	}
}
