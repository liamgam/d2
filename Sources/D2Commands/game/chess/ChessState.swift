import SwiftDiscord
import D2Permissions

public struct ChessState: GameState, CustomStringConvertible {
	public typealias Role = ChessRole
	public typealias Board = ChessBoard
	public typealias Move = ChessMove
	
	private let whitePlayer: GamePlayer
	private let blackPlayer: GamePlayer
	public private(set) var board = Board()
	public private(set) var currentRole: Role = .white
	public var description: String { return "`\(whitePlayer.username)` as :white_circle: vs. `\(blackPlayer.username)` as :black_circle:" }
	
	public var possibleMoves: Set<Move> {
		return [] // TODO
	}
	
	public var winner: Role? { return nil /* TODO */ }
	public var isDraw: Bool { return false /* TODO */ }
	
	public init(firstPlayer whitePlayer: GamePlayer, secondPlayer blackPlayer: GamePlayer) {
		self.whitePlayer = whitePlayer
		self.blackPlayer = blackPlayer
	}
	
	public mutating func perform(move: Move) throws {
		// TODO
	}
	
	public func playerOf(role: Role) -> GamePlayer? {
		switch role {
			case .white: return whitePlayer
			case .black: return blackPlayer
		}
	}
	
	public func rolesOf(player: GamePlayer) -> [Role] {
		var roles = [Role]()
		
		if player == whitePlayer { roles.append(.white) }
		if player == blackPlayer { roles.append(.black) }
		
		return roles
	}
}
