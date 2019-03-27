import SwiftDiscord

class CycleThroughCommand: StringCommand {
	let description = "Animates a sequence of characters"
	let requiredPermissionLevel = PermissionLevel.vip
	private let loops = 4
	private let timer = RepeatingTimer(interval: .milliseconds(500))
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !timer.isRunning else {
			output.append("Animation is alre ady running.")
			return
		}
		
		let frames = input.split(separator: " ")
		
		guard let firstFrame = frames.first else {
			output.append("Cannot create empty animation.")
			return
		}
		
		let client = context.client!
		let channelID = context.channel!.id
		
		client.sendMessage(DiscordMessage(content: String(firstFrame)), to: channelID) { sentMessage, _ in
			self.timer.schedule(nTimes: self.loops * frames.count) { i, _ in
				let frame = String(frames[i % frames.count])
				client.editMessage(sentMessage!.id, on: channelID, content: frame)
			}
		}
	}
}
