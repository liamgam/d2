import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let rawRangePattern = "\\d+\\.\\.[\\.<]\\d+"

// Matches the arguments, capturing the range
fileprivate let inputPattern = try! Regex(from: "^(\(rawRangePattern))")

public class ForCommand: StringBasedCommand {
	public let description = "Iterates through a range and prints the loop indices."
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	private let timer: RepeatingTimer
	private let maxRangeLength: Int
	
	public init(intervalSeconds: Int = 1, maxRangeLength: Int = 6) {
		timer = RepeatingTimer(interval: .seconds(intervalSeconds))
		self.maxRangeLength = maxRangeLength
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !timer.isRunning else {
			output.append("Cannot run multiple `for`-loops concurrently")
			return
		}
		
		guard let parsedArgs = inputPattern.firstGroups(in: input) else {
			output.append("Syntax error: For arguments need to match `[number](...|..<)[number]`")
			return
		}
		
		let rawRange = parsedArgs[1]
		
		if let range: LowBoundedIntRange = parseIntRange(from: rawRange) ?? parseClosedIntRange(from: rawRange) {
			if range.count <= maxRangeLength {
				timer.schedule(nTimes: range.count) { i, _ in
					output.append(String(range.lowerBound + i))
				}
			} else {
				output.append("Your range is too long!")
			}
		}
	}
}
