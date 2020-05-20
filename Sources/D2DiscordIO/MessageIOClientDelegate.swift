import SwiftDiscord
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2DiscordIO.MessageIOClientDelegate")

public class MessageIOClientDelegate: DiscordClientDelegate {
    private let inner: MessageDelegate
    private let sinkClient: MessageClient
    
    public init(inner: MessageDelegate, sinkClient: MessageClient) {
        log.debug("Creating delegate")
        self.inner = inner
        self.sinkClient = sinkClient
    }

    public func client(_ discordClient: DiscordClient, didConnect connected: Bool) {
        log.debug("Connected")
        inner.on(connect: connected, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDisconnectWithReason reason: String) {
        log.debug("Got disconnect with reason \(reason)")
        inner.on(disconnectWithReason: reason, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateChannel channel: DiscordChannel) {
        log.debug("Got channel create: \(channel.id)")
        inner.on(createChannel: channel.id.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDeleteChannel channel: DiscordChannel) {
        log.debug("Got channel delete: \(channel.id)")
        inner.on(deleteChannel: channel.id.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateChannel channel: DiscordChannel) {
        log.debug("Got channel update: \(channel.id)")
        inner.on(updateChannel: channel.id.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateGuild guild: DiscordGuild) {
        log.debug("Created guild")
        inner.on(createGuild: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDeleteGuild guild: DiscordGuild) {
        log.debug("Deleted guild")
        inner.on(deleteGuild: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateGuild guild: DiscordGuild) {
        log.debug("Updated guild")
        inner.on(updateGuild: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didAddGuildMember member: DiscordGuildMember) {
        log.debug("Added guild member: \(member.user.username)")
        inner.on(addGuildMember: member.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didRemoveGuildMember member: DiscordGuildMember) {
        log.debug("Removed guild member: \(member.user.username)")
        inner.on(removeGuildMember: member.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateGuildMember member: DiscordGuildMember) {
        log.debug("Updated guild member: \(member.user.username)")
        inner.on(updateGuildMember: member.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didReceivePresenceUpdate presence: DiscordPresence) {
        log.debug("Got presence update")
        inner.on(receivePresenceUpdate: presence.usingMessageIO, client: overlayClient(with: discordClient))
    }
    
    public func client(_ discordClient: DiscordClient, didCreateMessage message: DiscordMessage) {
        log.debug("Got message")
        inner.on(createMessage: message.usingMessageIO, client: overlayClient(with: discordClient))
    }

    private func overlayClient(with discordClient: DiscordClient) -> MessageClient {
        OverlayMessageClient(inner: sinkClient, name: discordClientName, me: discordClient.user?.usingMessageIO)
    }
}
