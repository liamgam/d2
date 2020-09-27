import D2Utils

public struct CodenamesBoardModel {
    public private(set) var cards: [[Card]]

    public var width: Int { cards[0].count }
    public var height: Int { cards.count }

    public init(width: Int = 5, height: Int = 5) {
        assert(width >= 3 && height >= 3, "Codenames board should be at least 3x3")

        let cardCount = width * height
        let teamAgentCount = (cardCount / 2) - 3
        let innocentCount = (cardCount - (2 * teamAgentCount)) - 1

        let teamAgents = CodenamesTeam.allCases.flatMap { Array(repeating: Agent.team($0), count: teamAgentCount) }
        let innocents = Array(repeating: Agent.innocent, count: innocentCount)
        var words = Words.nouns.randomlyChosen(count: cardCount)
        var agents = teamAgents + innocents + [.assasin]

        cards = (0..<height).map { y in (0..<width).map { x in
            guard let word = words.removeRandomElementBySwap() else { fatalError("Too few words for the codenames board, currently at y = \(y), x = \(x)") }
            guard let agent = agents.removeRandomElementBySwap() else { fatalError("Too few agents generated, this is a bug") }
            return Card(word: word, agent: agent)
        } }
    }

    public enum Agent {
        case team(CodenamesTeam)
        case innocent
        case assasin
    }

    public struct Card {
        public let word: String
        public let agent: Agent
        public var hidden: Bool = true
    }

    public subscript(y: Int, x: Int) -> Card {
        get { cards[y][x] }
        set { cards[y][x] = newValue }
    }
}
