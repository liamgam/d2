import D2NetAPIs
import D2MessageIO
import Utils

public class ChangeLogCommand: StringCommand {
    public let info = CommandInfo(
        category: .git,
        shortDescription: "Fetches the latest commits to D2's repo",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        GitHubCommitsQuery(user: "fwcd", repo: "d2").perform().listen {
            do {
                let commits = try $0.get()
                output.append(Embed(
                    title: ":clock: Latest Commits",
                    description: commits
                        .map { "[`\($0.sha.prefix(7))`](\($0.htmlUrl)) \($0.commit?.message.split(separator: "\n").first?.truncated(to: 100, appending: "...").nilIfEmpty ?? "_no message_")" }
                        .truncated(to: 10)
                        .joined(separator: "\n")
                ))
            } catch {
                output.append(error, errorText: "Could not fetch latest commits")
            }
        }
    }
}
