import D2MessageIO
import D2Permissions
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class RedditCommand: StringCommand {
	public let info = CommandInfo(
		category: .reddit,
		shortDescription: "Fetches a post from Reddit",
		longDescription: "Fetches a random top post from a given subreddit",
		requiredPermissionLevel: .vip
	)
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "www.reddit.com"
		components.path = "/r/\(input)/top.json"
		
		guard let url = components.url else {
			output.append("Error while creating URL.")
			return
		}
		
		print("Querying \(url)")
		
		// TODO: Use HTTPRequest
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.addValue("Discord application D2", forHTTPHeaderField: "User-Agent")
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				print(String(describing: error))
				output.append("Error while querying URL.")
				return
			}
			guard let data = data else {
				output.append("Missing data after querying URL.")
				return
			}
			
			do {
				let json = try JSONSerialization.jsonObject(with: data)
				let optionalPost = (json as? [String: Any])
					.flatMap { $0["data"] }
					.flatMap { $0 as? [String: Any] }
					.flatMap { $0["children"] }
					.flatMap { $0 as? [Any] }
					.flatMap { $0.isEmpty ? nil : $0[Int.random(in: 0..<$0.count)] }
					.flatMap { $0 as? [String: Any] }
					.flatMap { $0["data"] }
					.flatMap { $0 as? [String: Any] }
				
				if let post = optionalPost {
					let embed = Embed(
						title: post["title"].flatMap { $0 as? String },
						description: post["selftext"].flatMap { $0 as? String },
						image: post["url"]
						.flatMap { $0 as? String }
						.flatMap { ($0.hasSuffix(".jpg") || $0.hasSuffix(".png")) ? $0 : nil }
						.flatMap { URL(string: $0) }
						.map { Embed.Image(url: $0) }
					)
					output.append(embed)
				} else {
					output.append("No post found.")
					print(json)
				}
			} catch {
				print(String(describing: error))
				output.append("Error while decoding JSON.")
			}
		}.resume()
	}
}
