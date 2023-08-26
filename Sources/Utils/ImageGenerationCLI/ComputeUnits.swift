import ArgumentParser
import CoreML

enum ComputeUnits: String, ExpressibleByArgument, CaseIterable {
	case all, cpuAndGPU, cpuOnly, cpuAndNeuralEngine
	var asMLComputeUnits: MLComputeUnits {
		switch self {
			case .all: return .all
			case .cpuAndGPU: return .cpuAndGPU
			case .cpuOnly: return .cpuOnly
			case .cpuAndNeuralEngine: return .cpuAndNeuralEngine
		}
	}
}
