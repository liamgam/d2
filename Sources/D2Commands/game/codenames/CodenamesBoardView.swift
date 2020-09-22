import D2Utils
import D2Graphics

struct CodenamesBoardView {
    let image: Image

    init(model: CodenamesBoardModel) throws {
        let intPadding = 5
        let padding = Double(intPadding)
        let fieldIntSize = Vec2<Int>(x: 100, y: 50)
        let fieldSize = fieldIntSize.asDouble
        let intSize = (fieldIntSize + Vec2<Int>(both: intPadding)) * Vec2<Int>(x: model.width, y: model.height)

        let image = try Image(fromSize: intSize)
        var graphics = CairoGraphics(fromImage: image)

        for y in 0..<model.height {
            for x in 0..<model.width {
                let card = model[y, x]
                let color = Self.colorOf(card: card)
                graphics.draw(Rectangle(fromX: Double(x) * (fieldSize.x + padding), y: Double(y) * (fieldSize.y + padding), width: fieldSize.x, height: fieldSize.y, color: color))
            }
        }

        self.image = image
    }

    private static func colorOf(card: CodenamesBoardModel.Card) -> Color {
        if card.hidden {
            return Color(rgb: 0xe0e0e0)
        } else {
            switch card.agent {
                case .role(.red): return Color(rgb: 0xad2a10)
                case .role(.blue): return Color(rgb: 0x101dad)
                case .innocent: return Color(rgb: 0xf5efc6)
                case .assasin: return Colors.black
            }
        }
    }
}
