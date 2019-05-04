import Foundation

public enum WebApiError: Error {
	case missingApiKey(String)
	case missingData
	case encodingError(String)
	case urlStringError(String)
	case urlError(URLComponents)
	case httpError(Error)
	case xmlError(String, Any)
	case imageError(String)
	case jsonIOError(Error)
	case jsonParseError(Any, String)
	case foundNoMatches(String)
	case noResults(String)
}