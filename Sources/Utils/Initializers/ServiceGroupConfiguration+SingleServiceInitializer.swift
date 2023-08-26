import ServiceLifecycle
import Logging

extension ServiceGroupConfiguration {
	init(service: Service, logger: Logger) {
		self.init(services: [service], logger: logger)
	}
}
