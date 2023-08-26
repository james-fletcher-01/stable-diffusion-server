import Foundation
import Logging
import Puppy

enum Logging {
	static let logger = makeLogger()
	
	private static func makeLogger() -> Logger {
		LoggingSystem.bootstrap { label in
			let formatter = LogFormatter()
			let console = ConsoleLogger(label, logFormat: formatter)
			let logger = Puppy(logger: console)
			return PuppyLogHandler(label: label, puppy: logger, logLevel: .trace)
		}
		
		return Logger(label: ProcessInfo.processInfo.processName)
	}
}
