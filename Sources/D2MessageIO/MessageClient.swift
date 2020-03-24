import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias ClientCallback<T> = (T, HTTPURLResponse?) -> Void

fileprivate func defaultCallback<T>(_ dummy: T, error: HTTPURLResponse?) {
	if let err = error {
		print(err)
	}
}

public protocol MessageClient {
	var me: User? { get } // Me
	
	func setPresence(_ presence: PresenceUpdate)
	
	func guildForChannel(_ channelId: ChannelID) -> Guild?
	
	func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?)

	func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?)
	
	func createDM(with user: UserID, then: ClientCallback<ChannelID>?)
	
	func sendMessage(_ message: Message, to channelId: ChannelID, then: ClientCallback<Message?>?)
	
	func editMessage(_ id: MessageID, on channelId: ChannelID, content: String, then: ClientCallback<Message?>?)
	
	func deleteMessage(_ id: MessageID, on channelId: ChannelID, then: ClientCallback<Bool>?)
	
	func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID, then: ClientCallback<Bool>?)
	
	func getMessages(for channelId: ChannelID, limit: Int, then: ClientCallback<[Message]>?)
	
	func triggerTyping(on channelId: ChannelID, then: ClientCallback<Bool>?)
	
	func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, then: ClientCallback<Message?>?)
}

public extension MessageClient {
	func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String? = nil) {
		addGuildMemberRole(roleId, to: userId, on: guildId, reason: reason, then: defaultCallback)
	}

	func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String? = nil) {
		removeGuildMemberRole(roleId, from: userId, on: guildId, reason: reason, then: defaultCallback)
	}

	func createDM(with user: UserID) {
		createDM(with: user, then: defaultCallback)
	}
	
	func sendMessage(_ message: Message, to channelId: ChannelID) {
		sendMessage(message, to: channelId, then: defaultCallback)
	}
	
	func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) {
		editMessage(id, on: channelId, content: content, then: defaultCallback)
	}
	
	func getMessages(for channelId: ChannelID, limit: Int) {
		getMessages(for: channelId, limit: limit, then: defaultCallback)
	}
	
	func triggerTyping(on channelId: ChannelID) {
		triggerTyping(on: channelId, then: defaultCallback)
	}
	
	func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) {
		createReaction(for: messageId, on: channelId, emoji: emoji, then: defaultCallback)
	}
}
