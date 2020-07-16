import D2MessageIO

/// Anything that handles incoming reactions
/// to messages from Discord.
public protocol ReactionHandler {
    mutating func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient)

    mutating func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient)

    mutating func handle(deletedAllReactionsFrom messageId: MessageID, on channelId: ChannelID, client: MessageClient)
}

public extension ReactionHandler {
    func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {}

    func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {}

    func handle(deletedAllReactionsFrom messageId: MessageID, on channelId: ChannelID, client: MessageClient) {}
}
