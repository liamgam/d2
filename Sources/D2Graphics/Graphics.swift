import D2Utils

public protocol Graphics {
	mutating func save()
	
	mutating func restore()
	
	mutating func translate(by offset: Vec2<Double>)
	
	mutating func rotate(by angle: Double)
	
	mutating func draw(_ line: LineSegment<Double>)
	
	mutating func draw(_ rect: Rectangle<Double>)
	
	mutating func draw(_ ellipse: Ellipse<Double>)
	
	mutating func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>, rotation: Double)
	
	mutating func draw(_ text: Text)
}

public extension Graphics {
	mutating func draw(_ image: Image) {
		draw(image, at: Vec2(x: 0, y: 0))
	}
	
	mutating func draw(_ image: Image, at position: Vec2<Double>) {
		draw(image, at: position, withSize: image.size)
	}
	
	mutating func draw(_ image: Image, at position: Vec2<Double>, rotation: Double) {
		draw(image, at: position, withSize: image.size, rotation: rotation)
	}
	
	mutating func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>) {
		draw(image, at: position, withSize: image.size, rotation: 0)
	}
}
