import D2MessageIO
import D2Utils
import Foundation

public class UserCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a user's presence",
        longDescription: "Fetches information about a user's status and currently played game",
        requiredPermissionLevel: .vip
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append("Not on a guild.")
            return
        }
        guard let user = context.message.mentions.first else {
            output.append("Please mention someone!")
            return
        }
        guard let member = guild.members[user.id] else {
            output.append("Not a guild member.")
            return
        }
        let presence = guild.presences[user.id]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"

        output.append(Embed(
            title: "\(user.username)#\(user.discriminator)",
            thumbnail: URL(string: "https://cdn.discordapp.com/avatars/\(user.id)/\(user.avatar).png?size=128").map { Embed.Thumbnail(url: $0) },
            footer: Embed.Footer(text: "ID: \(user.id)"),
            fields: [
                Embed.Field(name: "Nick", value: member.nick ?? "_none_"),
                Embed.Field(name: "Roles", value: guild.roles(for: member).sorted(by: descendingComparator { $0.position }).map { $0.name }.joined(separator: "\n").nilIfEmpty ?? "_none_"),
                Embed.Field(name: "Voice Status", value: ((member.deaf ? ["deaf"] : []) + (member.mute ? ["mute"] : [])).joined(separator: ", ").nilIfEmpty ?? "_none_"),
                Embed.Field(name: "Joined at", value: dateFormatter.string(from: member.joinedAt))
            ] + (presence.map { [
                Embed.Field(name: "Status", value: stringOf(status: $0.status))
            ] + ($0.game.map { [
                Embed.Field(name: "Activity", value: """
                    Name: \($0.name)
                    Assets: \($0.assets.flatMap { [$0.largeText, $0.smallText].compactMap { $0 }.joined(separator: ", ").nilIfEmpty } ?? "_none_")
                    Details: \($0.details ?? "_none_")
                    Party: \($0.party.map { "\($0.id) - sizes: \($0.sizes ?? [])" } ?? "_none_")
                    State: \($0.state ?? "_none_")
                    Type: \(stringOf(activityType: $0.type))
                    Timestamps: playing for \($0.timestamps?.interval?.displayString ?? "unknown amount of time")
                    """)
            ] } ?? []) } ?? [])
        ))
    }
    
    private func stringOf(status: Presence.Status) -> String {
        switch status {
            case .idle: return ":yellow_circle: Idle"
            case .online: return ":green_circle: Online"
            case .offline: return ":white_circle: Offline"
            case .doNotDisturb: return ":red_circle: Do not disturb"
        }
    }
    
    private func stringOf(activityType: Presence.Activity.ActivityType) -> String {
        switch activityType {
            case .game: return ":video_game: Playing"
            case .listening: return ":musical_note: Listening"
            case .stream: return ":movie_camera: Streaming"
        }
    }
}
