import D2MessageIO
import Utils

public class GuildsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Fetches a list of guilds this bot is on",
        requiredPermissionLevel: .admin
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let guilds = context.client?.guilds else {
            output.append(errorText: "Could not fetch guilds")
            return
        }

        output.append(Embed(
            title: ":accordion: Guilds",
            fields: guilds.sorted(by: descendingComparator { $0.members.count }).map {
                Embed.Field(
                    name: $0.name,
                    value: [
                        $0.members[$0.ownerId].map { "owned by `\($0.user.username)#\($0.user.discriminator)` (<@\($0.user.id)>)" },
                        "\($0.members.count) \("member".pluralized(with: $0.members.count))",
                        "\($0.channels.count) \("channel".pluralized(with: $0.channels.count))",
                        "\($0.id)"
                    ].compactMap { $0 }.joined(separator: "\n"),
                    inline: true
                )
            }
        ))
    }
}
