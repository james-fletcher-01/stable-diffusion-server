import ArgumentParser
import StableDiffusion

enum RNGOption: String, ExpressibleByArgument {
	case numpy, torch
	var stableDiffusionRNG: StableDiffusionRNG {
		switch self {
			case .numpy: return .numpyRNG
			case .torch: return .torchRNG
		}
	}
}
