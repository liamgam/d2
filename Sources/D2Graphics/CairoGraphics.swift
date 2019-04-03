import Cairo
import D2Utils

public struct CairoGraphics: Graphics {
	private let context: Cairo.Context
	
	init(surface: Surface) {
		context = Cairo.Context(surface: surface)
	}
	
	public init(fromImage image: Image) {
		self.init(surface: image.surface)
	}
	
	public mutating func save() {
		context.save()
	}
	
	public mutating func restore() {
		context.restore()
	}
	
	public mutating func translate(by offset: Vec2<Double>) {
		context.translate(x: offset.x, y: offset.y)
	}
	
	public mutating func rotate(by angle: Double) {
		context.rotate(angle)
	}
	
	public mutating func draw(_ line: LineSegment<Double>) {
		context.setSource(color: line.color.asDoubleTuple)
		context.move(to: line.start.asTuple)
		context.line(to: line.end.asTuple)
		context.stroke()
	}
	
	public mutating func draw(_ rect: Rectangle<Double>) {
		// Floating point comparison is intended since this flag only allows potential optimizations
		var rotated = false
		
		if let rotation = rect.rotation {
			context.save()
			context.rotate(rotation)
			rotated = true
		}
		
		context.setSource(color: rect.color.asDoubleTuple)
		context.addRectangle(x: rect.topLeft.x, y: rect.topLeft.y, width: rect.width, height: rect.height)
		
		if rect.isFilled {
			context.fill()
		} else {
			context.stroke()
		}
		
		if rotated {
			context.restore()
		}
	}
	
	public mutating func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>, rotation: Double) {
		let originalWidth = image.width
		let originalHeight = image.height
		
		context.save()
		
		let scaleFactor = Vec2(x: Double(size.x) / Double(originalWidth), y: Double(size.y) / Double(originalHeight))
		context.translate(x: position.x, y: position.y)
		
		if rotation != 0.0 {
			let center = (size / 2).asDouble
			context.translate(x: center.x, y: center.y)
			context.rotate(rotation)
			context.translate(x: -center.x, y: -center.y)
		}
		
		if originalWidth != size.x || originalHeight != size.y {
			context.scale(x: scaleFactor.x, y: scaleFactor.y)
		}
		
		context.source = Pattern(surface: image.surface)
		context.paint()
		context.restore()
	}
	
	public mutating func draw(_ text: Text) {
		context.setSource(color: text.color.asDoubleTuple)
		context.setFont(size: text.fontSize)
		context.move(to: text.position.asTuple)
		context.show(text: text.value)
	}
	
	public mutating func draw(_ ellipse: Ellipse<Double>) {
		context.save()
		context.setSource(color: ellipse.color.asDoubleTuple)
		context.translate(x: ellipse.center.x, y: ellipse.center.y)
		context.rotate(ellipse.rotation)
		context.scale(x: ellipse.radius.x, y: ellipse.radius.y)
		context.addArc(center: (x: 0.0, y: 0.0), radius: 1.0, angle: (0, 2.0 * Double.pi))
		context.fill()
		context.restore()
	}
}
