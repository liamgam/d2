import SwiftDiscord
import D2MessageIO

// FROM Discord conversions

extension DiscordGuild: MessageIOConvertible {
	public var usingMessageIO: Guild {
		return Guild(
			id: id.usingMessageIO,
			ownerId: ownerId.usingMessageIO,
			region: region,
			large: large,
			name: name,
			joinedAt: joinedAt,
			splash: splash,
			unavailable: unavailable,
			description: description,
			mfaLevel: mfaLevel,
			verificationLevel: verificationLevel,
			embedEnabled: embedEnabled,
			embedChannelId: embedChannelId.usingMessageIO,
			icon: icon,
			members: members.usingMessageIO,
			roles: roles.usingMessageIO,
			presences: presences.usingMessageIO,
			voiceStates: voiceStates.usingMessageIO,
			emojis: emojis.usingMessageIO,
			channels: Dictionary(uniqueKeysWithValues: channels.map { (k, v) in (k.usingMessageIO, v.usingMessageIO) })
		)
	}
}

extension DiscordGuildChannel /* TODO: No protocol inheritance clauses: MessageIOConvertible */ {
	public var usingMessageIO: Guild.Channel {
		return Guild.Channel(
			guildId: guildId.usingMessageIO,
			name: name,
			parentId: parentId?.usingMessageIO,
			position: position,
			isVoiceChannel: self is DiscordGuildVoiceChannel,
			permissionOverwrites: permissionOverwrites.usingMessageIO
		)
	}
}

extension DiscordPermissionOverwrite: MessageIOConvertible {
	public var usingMessageIO: Guild.Channel.PermissionOverwrite {
		return Guild.Channel.PermissionOverwrite(
			id: id.usingMessageIO,
			type: type.usingMessageIO
		)
	}
}

extension DiscordPermissionOverwriteType: MessageIOConvertible {
	public var usingMessageIO: Guild.Channel.PermissionOverwrite.PermissionOverwriteType {
		switch self {
			case .role: return .role
			case .member: return .member
		}
	}
}

extension DiscordGuildMember: MessageIOConvertible {
	public var usingMessageIO: Guild.Member {
		return Guild.Member(
			guildId: guildId.usingMessageIO,
			joinedAt: joinedAt,
			user: user.usingMessageIO,
			deaf: deaf,
			mute: mute,
			roleIds: roleIds.usingMessageIO
		)
	}
}