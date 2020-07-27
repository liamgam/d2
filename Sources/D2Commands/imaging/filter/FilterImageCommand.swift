import D2Utils
import D2Graphics

public class FilterImageCommand<F: ImageFilter>: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Applies an image convolution filter",
        requiredPermissionLevel: .basic
    )
    private let maxSize: Int

    public init(maxSize: Int = 15) {
        self.maxSize = maxSize
    }

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Not an image")
            return
        }

        guard let size = input.asText.map(Int.init) ?? 3 else {
            output.append(errorText: "Please provide an integer for specifying the filter size!")
            return
        }

        guard size <= maxSize else {
            output.append(errorText: "Please use a filter size smaller or equal to \(maxSize)!")
            return
        }

        do {
            let width = image.width
            let height = image.height
            var result = try Image(width: width, height: height)
            let filterMatrix = F.init(size: size).matrix
            let halfMatrixWidth = filterMatrix.width / 2
            let halfMatrixHeight = filterMatrix.height / 2

            let pixels = (0..<height).map { y in (0..<width).map { x in image[y, x] } }

            func apply(factor: Double, to channel: UInt8, over base: UInt8) -> UInt8 {
                UInt8(max(0, min(255, Double(base) + Double(channel) * factor)))
            }
            
            // Perform the convolution
            for y in 0..<height {
                for x in 0..<width {
                    var value: Color = Colors.transparent
                    for dy in 0..<filterMatrix.height {
                        for dx in 0..<filterMatrix.width {
                            let pixel = pixels[max(0, min(height - 1, y + dy - halfMatrixHeight))][max(0, min(width - 1, x + dx - halfMatrixWidth))]
                            let factor = filterMatrix[dy, dx]

                            value = Color(
                                red: apply(factor: factor, to: pixel.red, over: value.red),
                                green: apply(factor: factor, to: pixel.green, over: value.green),
                                blue: apply(factor: factor, to: pixel.blue, over: value.blue),
                                alpha: apply(factor: factor, to: pixel.alpha, over: value.alpha)
                            )
                        }
                    }
                    result[y, x] = value
                }
            }

            try output.append(result)
        } catch {
            output.append(error, errorText: "Error while processing image")
        }
    }
}
