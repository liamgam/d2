import D2Utils

struct PlaceholderNode: ExpressionASTNode {
	let name: String
	let isConstant = false
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		if let value = feedDict[name] {
			return value
		} else {
			throw ExpressionError.noValueForPlaceholder(name)
		}
	}
}