import Foundation

enum UnivISError: Error {
	case missingData
	case urlError(URLComponents)
	case httpError(Error)
	case xmlError(String, Any)
}