import SwiftDiscord
import D2Utils

fileprivate let setMessageRegex = try! Regex(from: "set\\s+(\\S+)\\s+(\\S+)")
fileprivate let cancelMessageRegex = try! Regex(from: "cancel\\s+(\\S+)")

class TicTacToeCommand: StringCommand {
	let description = "Plays tic-tac-toe against someone"
	let requiredPermissionLevel = PermissionLevel.basic
	let subscribesToNextMessages = true
	
	var currentMatch: TicTacToeMatch? = nil
	
	private enum Row: String, CaseIterable {
		case top
		case center
		case bottom
		
		var index: Int {
			switch self {
				case .top: return 0
				case .center: return 1
				case .bottom: return 2
			}
		}
	}
	
	private enum Column: String, CaseIterable {
		case left
		case center
		case right
		
		var index: Int {
			switch self {
				case .left: return 0
				case .center: return 1
				case .right: return 2
			}
		}
	}
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard currentMatch == nil else {
			output.append("Wait for the current match to finish before creating a new one.")
			return
		}
		
		guard let opponent = context.message.mentions.first else {
			output.append("Mention an opponent to play against.")
			return
		}
		
		let playerX = context.author
		let playerO = opponent
		let match = TicTacToeMatch(firstPlayer: playerX, secondPlayer: playerO)
		
		currentMatch = match
		output.append("Playing new match: \(match)\n\(match.board.discordEncoded)")
	}
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		if let match = currentMatch {
			if let setArgs = setMessageRegex.firstGroups(in: content) {
				return handleSetMessage(withMatch: match, setArgs: setArgs, output: output, context: context)
			} else if let cancelArgs = cancelMessageRegex.firstGroups(in: content) {
				return handleCancelMessage(withMatch: match, cancelArgs: cancelArgs, output: output, context: context)
			}
		}
		return .continueSubscription
	}
	
	func handleSetMessage(withMatch match: TicTacToeMatch, setArgs: [String], output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		let roles = match.rolesOf(player: context.author)
		
		guard roles.contains(match.currentRole) else {
			print("Current player: \(match.currentRole), roles: \(roles)")
			output.append("It is not your turn, `\(context.author.username)`")
			return .continueSubscription
		}
		
		let role = match.currentRole
		let rowIndex: Int
		let colIndex: Int
		
		if let row = Row(rawValue: setArgs[1]), let col = Column(rawValue: setArgs[2]) {
			rowIndex = row.index
			colIndex = col.index
		} else if let row = Row(rawValue: setArgs[2]), let col = Column(rawValue: setArgs[1]) {
			rowIndex = row.index
			colIndex = col.index
		} else if let row = Int(setArgs[1]), let col = Int(setArgs[2]) {
			rowIndex = row
			colIndex = col
		} else {
			output.append("Invalid coordinates, try a combination of `\(Row.allCases.map { $0.rawValue })` and `\(Column.allCases.map { $0.rawValue })` with the syntax: `set [row] [column]` or `set [column] [row]`")
			return .continueSubscription
		}
		
		do {
			try match.performMoveAt(row: rowIndex, col: colIndex)
			output.append(match.board.discordEncoded)
			
			if let winner = match.board.winner {
				var embed = DiscordEmbed()
				
				// Game over
				if let winnerPlayer = match.playerOf(role: winner) {
					embed.title = ":crown: Winner"
					embed.description = "\(winner.discordEncoded) aka. `\(winnerPlayer.username)` won the game!"
				} else {
					embed.title = ":crown: Game Over"
					embed.description = "The game resulted in a draw!"
				}
				
				output.append(embed)
				currentMatch = nil
				return .cancelSubscription
			}
		} catch TicTacToeError.invalidMove(let role, let row, let col) {
			output.append("Invalid move by \(role.discordEncoded): Could not place at `[row = \(row), col = \(col)]`")
		} catch TicTacToeError.outOfBounds(let row, let col) {
			output.append("Out of bounds: `[row = \(row), col = \(col)]`")
		} catch {
			output.append("Error while attempting move")
			print(error)
		}
		return .continueSubscription
	}
	
	func handleCancelMessage(withMatch match: TicTacToeMatch, cancelArgs: [String], output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		let arg = cancelArgs[1]
		switch arg {
			case "match":
				currentMatch = nil
				output.append("Cancelled match: \(match)")
				return .cancelSubscription
			default:
				output.append("Sorry, I do not know how to cancel `\(arg)`")
		}
		return .continueSubscription
	}
}
