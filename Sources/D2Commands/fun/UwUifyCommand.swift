import D2Utils

fileprivate let wPattern = try! Regex(from: "[rl]")
fileprivate let punctuationPattern = try! Regex(from: "[!\\.]")

public class UwUifyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Transforms the text into an uwuish form",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let withWs = wPattern.replace(in: input, with: "w")
        let transformed = punctuationPattern.replace(in: withWs) { "\($0[0]) \(["UwU", "OwO", ">w<", "oωo", ".ω."].randomElement()!)." }
        output.append(transformed)
    }
}
