import D2Utils

public struct TwirlTransform: ImageTransform {
    private let pos: Vec2<Int>?
    private let scale: Double
    private let rotationBias: Double
    private let rotationStrength: Double

    public init(at pos: Vec2<Int>?, kvArgs: [String: String]) {
        self.pos = pos
        scale = kvArgs["scale"].flatMap { Double($0) } ?? 1
        rotationBias = kvArgs["rotationBias"].flatMap { Double($0) } ?? 0
        rotationStrength = kvArgs["rotationStrength"].flatMap { Double($0) } ?? 1
    }
    
    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let center = pos ?? (imageSize / 2)
        let delta = (destPos - center).asDouble
        let normalizedDist = (delta.magnitude * scale) / Double(imageSize.y)
        return center + (Mat2<Double>.rotation(by: 2 * Double.pi * (normalizedDist * rotationStrength + rotationBias) * percent) * delta).floored
    }
}
