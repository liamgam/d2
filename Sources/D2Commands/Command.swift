import D2MessageIO
import D2Permissions

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
public protocol Command: class {
	var inputValueType: RichValueType { get }
	var outputValueType: RichValueType { get }
	var info: CommandInfo { get }
	
	func invoke(input: RichValue, output: CommandOutput, context: CommandContext)
	
	func onSuccessfullySent(message: Message)
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext)

	func onReceivedUpdated(presence: DiscordPresence)
	
	func equalTo(_ rhs: Command) -> Bool
}

extension Command {
	public var inputValueType: RichValueType { .unknown }
	public var outputValueType: RichValueType { .unknown }
	
	public func onSuccessfullySent(message: Message) {}
	
	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {}
	
	public func onReceivedUpdated(presence: DiscordPresence) {}

	public func equalTo(_ rhs: Command) -> Bool { self === rhs }
}
