import D2MessageIO
import Logging

fileprivate let log = Logger(label: "DemoDelegate")

public class DemoDelegate: MessageDelegate {
	public func on(createMessage message: Message, client: MessageClient) {
		log.info("Created message \(message.content)")
	}
}