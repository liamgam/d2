import SwiftDiscord
import D2MessageIO

// FROM Discord conversions

extension DiscordRole: MessageIOConvertible {
	var usingMessageIO: Role {
		return Role(
			id: id.usingMessageIO,
			color: color,
			hoist: hoist,
			managed: managed,
			mentionable: mentionable,
			name: name,
			position: position
		)
	}
}
