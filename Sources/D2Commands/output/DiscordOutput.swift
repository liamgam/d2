import SwiftDiscord
import Foundation

public class DiscordOutput: CommandOutput {
	private let messageWriter = DiscordMessageWriter()
	private let client: DiscordClient
	private let defaultTextChannel: DiscordTextChannel?
	public let messageLengthLimit: Int? = 1800
	private let onSent: ((DiscordMessage?, HTTPURLResponse?) -> Void)?
	
	public init(client: DiscordClient, defaultTextChannel: DiscordTextChannel?, onSent: ((DiscordMessage?, HTTPURLResponse?) -> Void)? = nil) {
		self.client = client
		self.defaultTextChannel = defaultTextChannel
		self.onSent = onSent
	}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		var message: DiscordMessage
		do {
			message = try messageWriter.write(value: value)
		} catch {
			print("Error while encoding message:")
			print(error)
			message = DiscordMessage(content: """
				An error occurred while encoding the message:
				```
				\(error)
				```
				""")
		}
		switch channel {
			case .serverChannel(let id): client.sendMessage(message, to: id)
			case .userChannel(let id):
				client.createDM(with: id) { ch, _ in
					if let channelId = ch.map({ $0.id }) {
						self.client.sendMessage(message, to: channelId, callback: self.onSent)
					} else {
						print("Could not find user channel \(id)")
					}
				}
			case .defaultChannel:
				if let textChannel = defaultTextChannel {
					client.sendMessage(message, to: textChannel.id, callback: onSent)
				} else {
					print("No default text channel available")
				}
		}
	}
}
