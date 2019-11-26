import Foundation

public protocol CountdownGoal {
    var date: Date { get }
    var removeAfterCompletion: Bool { get }
    var hasCompleted: Bool { get }
}

public extension CountdownGoal {
    var hasCompleted: Bool { return date.timeIntervalSinceNow <= 0 }
}
