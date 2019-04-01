import D2Utils

/** Encapsulates an unpositioned chess piece. */
public protocol ChessPiece {
	var pieceType: ChessPieceType { get }
	
	/**
	 * Contains possible notation letters. The preferred letter
	 * (which is used for encoding) should be at the first position,
	 * if present.
	 */
	var notationLetters: [Character] { get }
	
	/**
	 * Fetches the possible moves of this piece.
	 *
	 * The implementor neither has to check if all moves are
	 * in the bounds of the board, nor whether
	 * the given move would result in a check.
	 */
	func possibleMoves(from position: Vec2<Int>, board: [[ColoredPieceType?]], role: ChessRole, firstMove: Bool) -> [Vec2<Int>]
}
