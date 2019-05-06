import D2Graphics

struct PerceptronRenderer {
	private let width: Int
	private let height: Int
	private let plotter: FunctionGraphRenderer
	
	init(
		width: Int = 300,
		height: Int = 300
	) {
		self.width = width
		self.height = height
		plotter = FunctionGraphRenderer(width: width, height: height)
	}
	
	func render(model: SingleLayerPerceptron) throws -> Image? {
		guard model.dimensions == 2 else { return nil }
		
		let image = try Image(width: width, height: height)
		var graphics: Graphics = CairoGraphics(fromImage: image)
		
		plotter.render(to: &graphics) { try? model.boundaryY(atX: $0) }
		
		for point in model.inputHistory {
			let x = plotter.pixelToFunctionX.inverseApply(point[0])
			let y = plotter.pixelToFunctionY.inverseApply(point[1])
			graphics.draw(Ellipse(centerX: x, y: y, radius: 3, color: Colors.white, isFilled: true))
		}
		
		return image
	}
}
