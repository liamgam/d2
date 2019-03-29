import SwiftDiscord
import D2Permissions

class HelpCommand: StringCommand {
	public let description = "Helps the user"
	public let requiredPermissionLevel = PermissionLevel.basic
	private let permissionManager: PermissionManager
	
	init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let helpText = Dictionary(grouping: context.registry.filter { !$0.value.hidden }, by: { $0.value.requiredPermissionLevel })
			.filter { permissionManager[context.author].rawValue >= $0.key.rawValue }
			.sorted { $0.key.rawValue < $1.key.rawValue }
			.map { group in ":star: \(group.key):\n```\n\(group.value.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value.description)" }.joined(separator: "\n"))\n```" }
			.joined(separator: "\n")
		output.append(helpText)
	}
}