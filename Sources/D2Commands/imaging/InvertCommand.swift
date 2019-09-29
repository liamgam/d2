import SwiftDiscord
import D2Permissions
import D2Graphics

public class InvertCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Inverts an image",
		longDescription: "Inverts the color of every pixel in the image",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .image
	public let outputValueType: RichValueType = .image
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		if case let .image(img) = input {
			do {
				let width = img.width
				let height = img.height
				var inverted = try Image(width: width, height: height)
				
				for y in 0..<height {
					for x in 0..<width {
						inverted[y, x] = img[y, x].inverted
					}
				}
				
				output.append(.image(inverted))
			} catch {
				output.append("An error occurred while creating a new image:\n`\(error)`")
			}
		} else {
			output.append("Error: Not an image!")
		}
	}
}
