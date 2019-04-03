public struct BoardPieceType {
	public let color: ChessRole
	public let pieceType: ChessPieceType
	public let moveCount: Int
	public var moved: Bool { return moveCount > 0 }
	
	public init(_ color: ChessRole, _ pieceType: ChessPieceType, moveCount: Int) {
		self.color = color
		self.pieceType = pieceType
		self.moveCount = moveCount
	}
}
