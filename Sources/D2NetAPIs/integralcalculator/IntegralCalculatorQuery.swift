import Foundation
import Logging
import D2Utils
import SwiftSoup

fileprivate let log = Logger(label: "D2NetAPIs.IntegralCalculatorQuery")
fileprivate let pageVersionPattern = try! Regex(from: "\\bpageVersion\\s*=\\s*(\\d+)\\b")

public struct IntegralCalculatorQuery<P: IntegralQueryParams> {
	private let params: P

	public init(params: P) {
		self.params = params
	}

	public func perform() -> Promise<IntegralQueryOutput, Error> {
		fetchPageVersion {
			switch $0 {
				case let .success(pageVersion):
					do {
						let params = String(data: try JSONEncoder().encode(self.params), encoding: .utf8) ?? ""
						log.info("Querying integral calculator v\(pageVersion) with params \(params)...")

						try HTTPRequest(
							scheme: "https",
							host: "www.integral-calculator.com",
							path: P.endpoint,
							method: "POST",
							query: [
								"q": params,
								"v": pageVersion
							]
						).fetchUTF8Async {
							switch $0 {
								case let .success(rawHTML):
									do {
										let document = try SwiftSoup.parse(rawHTML)
										let steps = try document.getElementsByClass("calc-math").map { try $0.text() }
										if steps.isEmpty {
											then(.failure(NetApiError.apiError(try document.text())))
										} else {
											then(.success(IntegralQueryOutput(steps: steps)))
										}
									} catch {
										then(.failure(error))
									}
								case let .failure(error):
									then(.failure(error))
							}
						}
					} catch {
						then(.failure(error))
					}
				case let .failure(error):
					then(.failure(error))
			}
		}
	}

	private func fetchPageVersion() -> Promise<String, Error> {
		do {
			try HTTPRequest(
				scheme: "https",
				host: "www.integral-calculator.com",
				path: "/",
				method: "GET"
			).fetchUTF8Async {
				switch $0 {
					case let .success(rawHTML):
						if let parsedPageVersion = pageVersionPattern.firstGroups(in: rawHTML) {
							then(.success(parsedPageVersion[1]))
						} else {
							then(.failure(NetApiError.apiError("Could not find page version of integral calculator")))
						}
					case let .failure(error):
						then(.failure(error))
				}
			}
		} catch {
			then(.failure(error))
		}
	}
}
