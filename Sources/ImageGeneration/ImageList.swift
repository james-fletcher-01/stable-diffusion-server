import Foundation

struct ImageList {
	private var images = [Int: [String]]()
	
	subscript(index: Int) -> [String] {
		mutating get {
			if(images[index] == nil) {
				images[index] = [String]()
			}
			return images[index]!
		}
		set {
			images[index] = newValue
		}
	}
	
	func getJSON() -> String {
		let images = convertToArray()
		
		let encoder = JSONEncoder()
		let data = try! encoder.encode(images)
		
		return String(data: data, encoding: .utf8)!
	}
	
	private func convertToArray() -> [[String]] {
		var imagesArray = [[String]]()
		for index in 0..<images.count {
			imagesArray.append(images[index]!)
		}
		
		return imagesArray
	}
}
