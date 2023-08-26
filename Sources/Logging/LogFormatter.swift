import Foundation
import Puppy

struct LogFormatter: LogFormattable {
	private static let dateFormatter = makeDateFormatter()
	
	func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String : String], label: String, date: Date, threadID: UInt64) -> String {
		let timestamp = Self.dateFormatter.string(from: date)
		let logDetails = getLogDetails(timestamp: timestamp, level: level, message: message, metadata: swiftLogInfo["metadata"])
		let logLine = logDetails.joined(separator: " ")
		return logLine.colorize(level.color)
	}
	
	private func getLogDetails(timestamp: String, level: LogLevel, message: String, metadata: String?) -> [String] {
		var logDetails = [String]()
		
		logDetails.append(timestamp)
		logDetails.append("\(level):")
		
		if let requestID = parseRequestID(from: metadata) {
			logDetails.append("[\(requestID)]")
		}
		
		logDetails.append(message)
		
		return logDetails
	}
	
	private func parseRequestID(from metadata: String?) -> String? {
		guard let metadata, !metadata.isEmpty else {
			return nil
		}
		
		let regex = #/(?:\[|,\s+)"requestID":\s+(?<requestID>.+?)[,\]]/#
		let result = metadata.firstMatch(of: regex)
		return result?.output.requestID.description
	}
}

extension LogFormatter {
	private static func makeDateFormatter() -> ISO8601DateFormatter {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
		dateFormatter.timeZone = .autoupdatingCurrent
		
		return dateFormatter
	}
}
