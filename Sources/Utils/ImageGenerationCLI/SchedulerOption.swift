import ArgumentParser
import StableDiffusion

enum SchedulerOption: String, ExpressibleByArgument {
	case pndm, dpmpp
	var stableDiffusionScheduler: StableDiffusionScheduler {
		switch self {
			case .pndm: return .pndmScheduler
			case .dpmpp: return .dpmSolverMultistepScheduler
		}
	}
}
