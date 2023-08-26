extension String {
	func trimmingWhitespace() -> Self {
		return self.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
