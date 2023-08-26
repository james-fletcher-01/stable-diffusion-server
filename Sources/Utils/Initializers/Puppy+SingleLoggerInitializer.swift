import Puppy

extension Puppy {
	init(logger: any Loggerable) {
		self.init(loggers: [logger])
	}
}
