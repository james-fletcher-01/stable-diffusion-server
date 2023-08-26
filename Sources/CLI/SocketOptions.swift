import Foundation
import ArgumentParser

struct SocketOptions: ParsableArguments {
	@Option(
		name: .shortAndLong,
		help: ArgumentHelp(
			"The Unix domain socket path to bind to.",
			discussion: "The socket must not exist, it will be created by the system."
		)
	)
	var socketPath: URL
	
	@Option(
		name: [.customLong("number-threads"), .customShort("t")],
		help: ArgumentHelp(
			"The number of threads to use when listening for requests.",
			discussion: """
				A value of higher than one allows requests to be handled simultaneously, but may slow down each request.
				By default, creates a thread for each available CPU core.
			"""
		)
	)
	var numberOfThreads: Int?
}
