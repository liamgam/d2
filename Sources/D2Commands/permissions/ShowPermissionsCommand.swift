import SwiftDiscord
import D2Permissions

public class ShowPermissionsCommand: Command {
	public let description = "Displays the configured permissions"
	public let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	public init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		output.append("```\n\(permissionManager.description)\n```")
	}
}
