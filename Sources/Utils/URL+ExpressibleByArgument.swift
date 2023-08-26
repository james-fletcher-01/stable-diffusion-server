import Foundation
import ArgumentParser

extension URL: ExpressibleByArgument {
	public init?(argument: String) {
		self.init(fileURLWithPath: argument)
	}
	
	public static var defaultCompletionKind: CompletionKind {
		.directory
	}
}

extension URL {
	var standardizedFileURLString: String {
		standardizedFileURL.path
	}
}
