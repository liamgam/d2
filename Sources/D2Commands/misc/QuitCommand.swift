import Foundation
import SwiftDiscord
import D2Permissions

public class QuitCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Quits",
        longDescription: "Terminates the running process",
        requiredPermissionLevel: .admin
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(":small_red_triangle_down: Quitting D2")
        exit(0)
    }
}