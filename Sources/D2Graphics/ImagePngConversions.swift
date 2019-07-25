extension Image {
	public init(fromPng data: Data) throws {
		self.init(from: try Surface.Image(png: data))
	}
	
	public init(fromPngFile url: URL) throws {
		let fileManager = FileManager.default
		guard fileManager.fileExists(atPath: url.path) else { throw DiskFileError.fileNotFound(url) }
		
		if let data = fileManager.contents(atPath: url.path) {
			try self.init(fromPng: data)
		} else {
			throw DiskFileError.noData("Image at \(url) contained no data")
		}
	}
	
	public init(fromPngFile filePath: String) throws {
		try self.init(fromPngFile: URL(fileURLWithPath: filePath))
	}
	
	public func pngEncoded() throws -> Data {
		return try surface.writePNG()
	}
}
