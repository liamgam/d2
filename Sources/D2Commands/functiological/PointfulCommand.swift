import Logging
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Commands.PointfulCommand")

public class PointfulCommand: StringCommand {
    public let info = CommandInfo(
        category: .functiological,
        shortDescription: "Pointful notation converter",
        longDescription: "Converts a Haskell expression into pointful notation",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .code

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            let pointful = try Shell().outputSync(for: "pointful", args: [input])
            output.append(.code(pointful ?? "No results", language: "haskell"))
        } catch {
            output.append(error, errorText: "An error occurred while converting to pointful notation")
        }
    }
}
