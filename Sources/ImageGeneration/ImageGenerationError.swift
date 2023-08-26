enum ImageGenerationError: Error {
	case resources(String)
	case saving(String)
	case unsupported(String)
}

extension ImageGenerationError {
	var errorString: String {
		switch self {
			case let .resources(error): return "Resources Error: \(error)"
			case let .saving(error): return "Saving Error: \(error)"
			case let .unsupported(error): return "Unsupported Error: \(error)"
		}
	}
}
