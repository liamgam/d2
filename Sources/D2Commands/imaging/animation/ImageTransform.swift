import D2Utils

/**
 * A (bijective) transformation function
 * that distorts the image.
 */
public protocol ImageTransform {
    init(args: String)
    
    /**
     * Inversely applies this function,
     * i.e. fetches the position of the pixel
     * in the source image given a destination
     * position.
     */
    func sourcePos(from destPos: Vec2<Int>, percent: Double) -> Vec2<Int>
}
