public struct CodenamesGame: Game {
    public typealias State = CodenamesState

    public let name: String = "Codenames"
    public let actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] = [
        "move": { ActionResult(nextState: try $0.state.childState(after: try CodenamesGame.parse(move: $0.args, from: $0.state.currentRole))) },
    ]
    public let helpText: String = """
        Codenames is a board game where the players have to guess words based on a set of hint-words. Each team has a spymaster that dictates a codeword and a count, from which the rest of the team has to guess the hint-words on the board.

        For more information on the rules, check out the Wikipedia article:
        <https://en.wikipedia.org/wiki/Codenames_(board_game)>

        When creating a Codenames game with D2, the first player in each team is assigned the role of the spymaster, i.e. if A invokes `codenames @B @C @D @E @F` (in that order), A, B, C are going to be the first team (with A being a spymaster) and D, E, F the second team (with D being a spymaster).

        If you've just started a new game, you are the spymaster for team red. Enter `move [word count] [codeword]` to begin, e.g.:

        - `move fruit 3` if you want your teammates to find 3 hint words on the board related to fruits
        - `move planet 2` if you want your teammates to find 2 hint words on the board related to hotels

        In general you want to think of a term that is as abstract as possible to cover as many words of your team color as possible. Beware of your opponent's cards and the assasin though!

        After that, _one_ of your teammates can perform a guess by entering `move [word1] [word2]...` with the words on the board, e.g.:

        - `move apple banana orange` as a guess for the codeword/count `fruit 3`
        - `move earth mars` as a guess for the codeword/count `planet 2`

        You might want to coordinate your guess among your teammates beforehand here.

        Subsequently, the respective cards will be uncovered and the blue team's spymaster has to mention a codeword (as described above). The game ends once a team has uncovered all of their cards or the opponent has uncovered the assasin.
        """

    public init() {}

    private static func parse(move rawMove: String, from role: CodenamesRole) throws -> State.Move {
        switch role {
            case .spymaster(_): return State.Move.codeword(rawMove)
            case .team(_): return State.Move.guess(rawMove.split(separator: " ").map(String.init))
        }
    }
}
