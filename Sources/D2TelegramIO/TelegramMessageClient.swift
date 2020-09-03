import D2Utils
import D2MessageIO
import Emoji
import Telegrammer
import Logging

fileprivate let log = Logger(label: "D2TelegramIO.TelegramMessageClient")

struct TelegramMessageClient: MessageClient {
    private let bot: Bot

    var me: D2MessageIO.User? { nil } // TODO
    var name: String { telegramClientName }
    var guilds: [Guild]? { nil }
    var messageFetchLimit: Int? { nil }

    init(bot: Bot) {
        self.bot = bot
    }

    func guild(for guildId: GuildID) -> Guild? {
        // TODO
        nil
    }

    func setPresence(_ presence: PresenceUpdate) {
        // TODO
    }

    func guildForChannel(_ channelId: ChannelID) -> Guild? {
        // TODO
        nil
    }

    func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permission {
        // TODO
        []
    }

    func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> D2Utils.Promise<Bool, Error> {
        // TODO
        D2Utils.Promise(.success(false))
    }

    func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> D2Utils.Promise<Bool, Error> {
        // TODO
        D2Utils.Promise(.success(false))
    }

    func createDM(with userId: UserID) -> D2Utils.Promise<ChannelID?, Error> {
        // TODO
        D2Utils.Promise(.success(nil))
    }

    private func flatten(embed: Embed) -> String {
        let lines: [String?] = [
            embed.title.flatMap { title in embed.url.map { "[\(title)](\($0.absoluteString))" } ?? title },
            embed.description
        ] + embed.fields.flatMap { ["**\($0.name)**", $0.value] } + [
            embed.footer?.text
        ]
        return lines
            .compactMap { $0 }
            .joined(separator: "\n")
    }

    func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> D2Utils.Promise<D2MessageIO.Message?, Error> {
        D2Utils.Promise { then in
            let text = [message.content, message.embed.map(flatten(embed:))]
                .compactMap { $0?.nilIfEmpty }
                .joined(separator: "\n")
                .emojiUnescapedString
            log.debug("Sending message '\(text)'")

            do {
                try bot.sendMessage(params: .init(chatId: .chat(channelId.usingTelegramAPI), text: text, parseMode: .markdown)).whenComplete {
                    do {
                        then(.success(try $0.get().usingMessageIO))
                    } catch {
                        log.warning("Could not send message to Telegram: \(error)")
                        then(.failure(error))
                    }
                }
            } catch {
                log.warning("Could not send message to Telegram: \(error)")
                then(.failure(error))
            }
        }
    }

    func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> D2Utils.Promise<D2MessageIO.Message?, Error> {
        // TODO
        D2Utils.Promise(.success(nil))
    }

    func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> D2Utils.Promise<Bool, Error> {
        // TODO
        D2Utils.Promise(.success(false))
    }

    func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> D2Utils.Promise<Bool, Error> {
        // TODO
        D2Utils.Promise(.success(false))
    }

    func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> D2Utils.Promise<[D2MessageIO.Message], Error> {
        // TODO
        D2Utils.Promise(.success([]))
    }

    func isGuildTextChannel(_ channelId: ChannelID) -> D2Utils.Promise<Bool, Error> {
        // TODO
        D2Utils.Promise(.success(false))
    }

    func isDMTextChannel(_ channelId: ChannelID) -> D2Utils.Promise<Bool, Error> {
        // TODO
        D2Utils.Promise(.success(false))
    }

    func triggerTyping(on channelId: ChannelID) -> D2Utils.Promise<Bool, Error> {
        // TODO
        D2Utils.Promise(.success(false))
    }

    func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> D2Utils.Promise<D2MessageIO.Message?, Error> {
        // TODO
        D2Utils.Promise(.success(nil))
    }

    func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> D2Utils.Promise<D2MessageIO.Emoji?, Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> D2Utils.Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }
}
