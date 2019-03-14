import Foundation
import Sword

func main() throws {
	// 'discordToken' should be declared in 'authtoken.swift'
	let client = Sword(token: discordToken)
	let handler = D2ClientHandler()
	
	client.on(.messageCreate) { handler.on(createMessage: $0 as! Message) }
	
	client.connect()
}

try main()
