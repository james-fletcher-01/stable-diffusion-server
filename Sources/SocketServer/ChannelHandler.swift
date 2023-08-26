import Foundation
import NIO
import Logging

final class ChannelHandler: ChannelInboundHandler {
	typealias InboundIn = ByteBuffer
	typealias OutboundOut = ByteBuffer
	
	func channelRead(context: ChannelHandlerContext, data: NIOAny) {
		let input = retrieveInput(from: data)
		guard let input, !input.isEmpty else { return }
		
		let requestID = UUID().uuidString
		let logger = getLogger(requestID: requestID)
		logger.info("Processing request")
		
		let future = context.eventLoop.makeFutureWithTask {
			let configuration = ImageConfiguration.makeConfiguration(input)
			let imageGenerator = ImageGenerator(requestID: requestID, configuration: configuration, logger: logger)
			return try imageGenerator.generate()
		}
		
		future.whenSuccess { output in
			self.sendOutput(output, context: context)
			logger.info("Request completed")
		}
		
		future.whenFailure { error in
			self.handleError(error: error, logger: logger)
			context.close(promise: nil)
		}
	}
	
	private func retrieveInput(from data: NIOAny) -> String? {
		let inputBuffer = unwrapInboundIn(data)
		let inputString = inputBuffer.getString(at: 0, length: inputBuffer.readableBytes)
		return inputString?.trimmingWhitespace()
	}
	
	private func sendOutput(_ output: String, context: ChannelHandlerContext) {
		let outputBuffer = createOutputBuffer(for: output, context: context)
		let outputData = wrapOutboundOut(outputBuffer)
		
		context.write(outputData, promise: nil)
		context.flush()
	}
	
	private func createOutputBuffer(for output: String, context: ChannelHandlerContext) -> OutboundOut {
		var outputBuffer = context.channel.allocator.buffer(capacity: output.count)
		outputBuffer.writeString(output)
		return outputBuffer
	}
	
	private func getLogger(requestID: String) -> Logger {
		var logger = Logging.logger
		logger.requestID = requestID
		return logger
	}
	
	private func handleError(error: Error, logger: Logger) {
		switch error {
			case let error as ImageGenerationError:
				logger.error("\(error.errorString)")
			default:
				logger.error("There was an error processing the images: \(error)")
		}
	}
}
