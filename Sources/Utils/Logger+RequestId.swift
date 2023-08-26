import Logging

extension Logger {
	private static var requestIDKey: String { "requestID" }
	
	var requestID: String? {
		get {
			return self[metadataKey: Self.requestIDKey]?.description
		}
		set {
			if let newValue {
				self[metadataKey: Self.requestIDKey] = .string(newValue)
			} else {
				self[metadataKey: Self.requestIDKey] = nil
			}
		}
	}
}
