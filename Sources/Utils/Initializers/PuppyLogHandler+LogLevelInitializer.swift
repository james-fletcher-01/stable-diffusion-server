import Puppy

extension PuppyLogHandler {
	init(label: String, puppy: Puppy, logLevel: Logger.Level) {
		self.init(label: label, puppy: puppy)
		self.logLevel = logLevel
	}
}
