public class RickrollCommand: Command {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Rickrolls someone",
        helpText: "Syntax: [user id]",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let messageId = context.message.id, let channelId = context.message.channelId else {
            output.append(errorText: "No message/channel id available")
            return
        }
        guard let client = context.client else {
            output.append(errorText: "No client available")
            return
        }
        guard let mentions = input.asMentions else {
            output.append(errorText: "Mention someone to start!")
            return
        }

        client.deleteMessage(messageId, on: channelId) { _, _ in
            let what = ["cool video", "meme compilation", "awesome remix", "great song", "tutorial", "nice trailer", "movie"].randomElement()!
            output.append("Hey, \(mentions.map { "<@\($0.id)>" }.joined(separator: " ")), check out this \(what): <https://www.youtube.com/watch?v=dQw4w9WgXcQ>")
        }
    }
}
