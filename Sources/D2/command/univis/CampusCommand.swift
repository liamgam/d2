import SwiftDiscord
import Foundation

fileprivate let addressWithCityPattern = try! Regex(from: ".+,\\s*\\d\\d\\d\\d\\d\\s+\\w+")

/** Locates locations on the University of Kiel's campus. */
class CampusCommand: Command {
	let description = "Locates rooms on the CAU campus"
	let requiredPermissionLevel = PermissionLevel.basic
	let geocoder = MapQuestGeocoder()
	
	func invoke(withMessage message: DiscordMessage, guild: DiscordGuild?, args: String) {
		do {
			try UnivISQuery(search: .rooms, params: [
				.name: args
			]).start { response in
				guard case let .ok(output) = response else {
					message.channel?.send("An error occurred while querying.")
					return
				}
				// Successfully received and parsed UnivIS query output
				guard let room = (output.childs.first { $0 is UnivISRoom }.map { $0 as! UnivISRoom }) else {
					message.channel?.send("No room was found!")
					return
				}
				guard let rawAddress = room.address else {
					message.channel?.send("Room has no address!")
					return
				}
				
				let address: String
				
				if addressWithCityPattern.matchCount(in: rawAddress) > 0 {
					address = rawAddress
				} else {
					address = rawAddress + ", 24118 Kiel"
				}
				
				self.geocoder.geocode(location: address) { geocodeResponse in
					guard case let .ok(coords) = geocodeResponse else {
						message.channel?.send(rawAddress)
						return
					}
					let mapURL = MapQuestStaticMap(
						latitude: coords.latitude,
						longitude: coords.longitude
					).url
					
					URLSession.shared.dataTask(with: URL(string: mapURL)!) { data, response, error in
						guard error == nil else {
							message.channel?.send("An error occurred while fetching image.")
							return
						}
						guard let data = data else {
							message.channel?.send("Missing data while fetching image.")
							return
						}
						
						message.channel?.send(DiscordMessage(
							content: rawAddress,
							files: [DiscordFileUpload(data: data, filename: "map.png", mimeType: "image/png")]
						))
					}.resume()
				}
			}
		} catch {
			print(error)
			message.channel?.send("An error occurred. Check the log for more information.")
		}
	}
}
