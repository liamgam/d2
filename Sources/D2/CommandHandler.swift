import SwiftDiscord
import Foundation

class CommandHandler: DiscordClientDelegate {
	private let commandPattern: Regex
	private var currentIndex = 0
	
	private(set) var registry = CommandRegistry()
	let permissionManager = PermissionManager()
	
	init(withPrefix msgPrefix: String) throws {
		// The first group matches the command name,
		// the second matches the arguments (the rest of the message content)
		commandPattern = try Regex(from: "^\(Regex.escape(msgPrefix))(\\w+)(?:\\s+([\\s\\S]*))?")
	}
	
	func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
		let msgIndex = currentIndex
		let fromBot = message.author.bot
		
		currentIndex += 1
		
		if !fromBot, let groups = commandPattern.firstGroups(in: message.content) {
			print("Got command #\(msgIndex): \(groups)")
			let name = groups[1]
			let args = groups[2]
			
			if let command = registry[name] {
				let hasPermission = permissionManager.user(message.author, hasPermission: command.requiredPermissionLevel)
				if hasPermission {
					print("Invoking '\(name)'")
					
					let context = CommandContext(
						guild: client.guildForChannel(message.channelId),
						registry: registry
					)
					command.invoke(withMessage: message, context: context, args: args)
				} else {
					print("Rejected '\(name)' due to insufficient permissions")
					message.channel?.send("Sorry, you are not permitted to execute `\(name)`.")
				}
			} else {
				print("Did not recognize command '\(name)'")
				message.channel?.send("Sorry, I do not know the command `\(name)`.")
			}
		}
	}
	
	subscript(name: String) -> Command? {
		get { return registry[name] }
		set(newValue) { registry[name] = newValue }
	}
}
