import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct HTTPRequest {
	private var request: URLRequest
	
	public init(
		scheme: String = "https",
		host: String,
		path: String,
		method: String = "GET",
		query: [String: String] = [:],
		headers: [String: String] = [:]
	) throws {
		let queryString = query.urlQueryEncoded
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		
		if method == "GET" {
			components.percentEncodedQuery = queryString
		}
		
		guard let url = components.url else { throw NetworkError.couldNotCreateURL(components) }
		
		request = URLRequest(url: url)
		request.httpMethod = method
		
		if method == "POST" {
			request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
			request.httpBody = queryString.data(using: .utf8)
		}
		
		for (key, value) in headers {
			request.setValue(value, forHTTPHeaderField: key)
		}
	}
	
	public func runAsync(then: @escaping (Result<Data, Error>) -> Void) {
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				then(.failure(NetworkError.ioError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(NetworkError.missingData))
				return
			}
			
			then(.success(data))
		}.resume()
	}
	
	public func fetchUTF8Async(then: @escaping (Result<String, Error>) -> Void) {
		runAsync {
			guard case let .success(data) = $0 else {
				guard case let .failure(error) = $0 else { fatalError("'Result' should always be either successful or insuccessful") }
				then(.failure(error))
				return
			}
			guard let utf8 = String(data: data, encoding: .utf8) else {
				then(.failure(NetworkError.notUTF8(data)))
				return
			}
			then(.success(utf8))
		}
	}
	
	public func fetchJSONAsync<T: Decodable>(as type: T.Type, then: @escaping (Result<T, Error>) -> Void) {
		runAsync {
			guard case let .success(data) = $0 else {
				guard case let .failure(error) = $0 else { fatalError("'Result' should always be either successful or insuccessful") }
				then(.failure(error))
				return
			}
			guard let deserialized = try? JSONDecoder().decode(type, from: data) else {
				then(.failure(NetworkError.jsonDecodingError(String(data: data, encoding: .utf8) ?? "<non-UTF-8-encoded data: \(data)>")))
				return
			}
			then(.success(deserialized))
		}
	}
}
