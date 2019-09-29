import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let flagRegex = try! Regex(from: "--(\\S+)")
fileprivate let actionMessageRegex = try! Regex(from: "^(\\S+)(?:\\s+(.+))?")

/**
 * Provides a base layer of functionality for a turn-based games.
 */
public class GameCommand<G: Game>: StringCommand {
	public let info: CommandInfo
	
	private let game: G
	private let defaultActions: [String: (G, ActionParameters<G.State>) throws -> ActionResult<G.State>] = [
		"cancel": { _, _ in ActionResult(cancelsMatch: true, onlyCurrentPlayer: false) },
		"help": { game, _ in ActionResult(text: game.helpText, onlyCurrentPlayer: false) }
	]
	private let defaultApiActions: Set<String> = ["cancel"]
	
	private var currentState: G.State? = nil
	private var apiEnabled: Bool = false
	private var silent: Bool = false
	
	public init() {
		game = G.init()
		info = CommandInfo(
			category: .game,
			shortDescription: "Plays \(game.name) against someone",
			longDescription: game.helpText,
			requiredPermissionLevel: .basic,
			subscribesToNextMessages: true,
			userOnly: false
		)
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard currentState == nil else {
			output.append("Wait for the current match to finish before creating a new one.")
			return
		}
		
		guard !context.message.mentions.isEmpty else {
			output.append("Mention one or more users to play against.")
			return
		}
		
		let flags = parseFlags(from: input)
		let players = ([context.author] + context.message.mentions).map { GamePlayer(from: $0) }
		
		startMatch(between: players, output: output, flags: flags)
	}
	
	private func parseFlags(from input: String) -> Set<String> {
		return Set(flagRegex.allGroups(in: input).map { $0[1] })
	}
	
	private func sendHandsAsDMs(fromState state: G.State, to output: CommandOutput) {
		if game.onlySendHandToCurrentRole, let player = state.playerOf(role: state.currentRole) {
			if let hand = state.hands[state.currentRole] {
				output.append(hand.asRichValue, to: .userChannel(player.id))
			}
		} else {
			for (role, hand) in state.hands {
				if let player = state.playerOf(role: role) {
					output.append(hand.asRichValue, to: .userChannel(player.id))
				}
			}
		}
	}
	
	func startMatch(between players: [GamePlayer], output: CommandOutput, flags: Set<String> = []) {
		let state = G.State.init(players: players)
		currentState = state
		apiEnabled = flags.contains("api")
		silent = flags.contains("silent")
		
		var encodedBoard: RichValue = .none
		
		if game.renderFirstBoard {
			encodedBoard = state.board.asRichValue
			
			if case .embed(_) = encodedBoard {
				print("Warning: Embed-encoded boards are currently not supported by GameCommand")
			}
		}
		
		output.append(.compound([
			encodedBoard,
			.embed(DiscordEmbed(
				title: "New match: \(state.playersDescription)",
				color: game.themeColor.map { Int($0.rgb) },
				footer: DiscordEmbed.Footer(text: "Type 'help' to begin!"),
				fields: [
					DiscordEmbed.Field(name: "Game actions", value: listFormat(game.actions.keys), inline: true),
					DiscordEmbed.Field(name: "General actions", value: listFormat(defaultActions.keys), inline: true)
				]
			))
		]))
		sendHandsAsDMs(fromState: state, to: output)
	}
	
	private func listFormat<T: Sequence>(_ sequence: T) -> String where T.Element: StringProtocol {
		return sequence.joined(separator: "\n")
	}
	
	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandEventAction {
		let author = GamePlayer(from: context.author)
		
		if let actionArgs = actionMessageRegex.firstGroups(in: content) {
			return perform(actionArgs[1], withArgs: actionArgs[2], output: output, author: author)
		} else {
			return .continueSubscription
		}
	}
	
	/** Performs a game action if present, otherwise does nothing. */
	@discardableResult
	func perform(_ actionKey: String, withArgs args: String, output: CommandOutput, author: GamePlayer) -> CommandEventAction {
		guard let state = currentState, (author.isUser || game.apiActions.contains(actionKey) || defaultApiActions.contains(actionKey)) else { return .continueSubscription }
		var subscriptionAction: CommandEventAction = .continueSubscription
		
		do {
			let params = ActionParameters(
				args: args,
				state: state,
				apiEnabled: apiEnabled
			)
			guard let actionResult = try game.actions[actionKey]?(params) ?? defaultActions[actionKey]?(game, params) else { return .continueSubscription }
			
			if actionResult.onlyCurrentPlayer {
				guard state.rolesOf(player: author).contains(state.currentRole) else {
					output.append("It is not your turn, `\(author.username)`")
					return .continueSubscription
				}
			}
			
			if actionResult.cancelsMatch {
				currentState = nil
				output.append("Cancelled match: \(state.playersDescription)")
				return .cancelSubscription
			}
			
			if let next = actionResult.nextState {
				// Output next board and user's hands
				var embed: DiscordEmbed? = nil
				
				// print("Next possible moves: \(next.possibleMoves)")
				sendHandsAsDMs(fromState: next, to: output)
				
				if let winner = next.winner {
					// Game won
					
					embed = DiscordEmbed(
						title: ":crown: Winner",
						description: "\(describe(role: winner, in: next)) won the game!"
					)
					
					currentState = nil
					subscriptionAction = .cancelSubscription
				} else if next.isDraw {
					// Game over due to a draw
					
					embed = DiscordEmbed(
						title: ":crown: Game Over",
						description: "The game resulted in a draw!"
					)
					
					currentState = nil
					subscriptionAction = .cancelSubscription
				} else {
					// Advance the game
					
					embed = DiscordEmbed(
						description: "\(actionResult.text ?? "")\nIt is now `\(next.playerOf(role: next.currentRole).map { $0.username } ?? "?")`'s turn"
					)
					
					currentState = next
				}
				
				if !silent || subscriptionAction == .cancelSubscription {
					let encodedBoard: RichValue = next.board.asRichValue
					output.append(.compound([
						encodedBoard,
						.embed(embed),
						.files(actionResult.files)
					]))
				}
			} else if let text = actionResult.text {
				output.append(text)
			}
		} catch GameError.invalidMove(let msg) {
			output.append("Invalid move by \(describe(role: state.currentRole, in: state)): \(msg)")
		} catch GameError.ambiguousMove(let msg) {
			output.append("Ambiguous move by \(describe(role: state.currentRole, in: state)): \(msg)")
		} catch GameError.incompleteMove(let msg) {
			output.append("Ambiguous move by \(describe(role: state.currentRole, in: state)): \(msg)")
		} catch GameError.moveOutOfBounds(let msg) {
			output.append("Move by \(describe(role: state.currentRole, in: state)) out of bounds: \(msg)")
		} catch {
			output.append("Error while attempting move")
			print(error)
		}
		
		return subscriptionAction
	}
	
	private func describe(role: G.State.Role, in state: G.State) -> String {
		return "\(role.asRichValue.asText ?? "")\(state.playerOf(role: role).map { " aka. `\($0.username)`" } ?? "")"
	}
}
