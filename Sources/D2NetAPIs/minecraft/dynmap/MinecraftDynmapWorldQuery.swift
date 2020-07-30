import Foundation
import D2Utils

public struct MinecraftDynmapWorldQuery {
    private let host: String
    private let world: String

    public init(host: String, world: String) {
        self.host = host
        self.world = world
    }

    public func perform() -> Promise<MinecraftDynmapWorld, Error> {
        .catchingThen {
            let timestamp = Int(Date().timeIntervalSince1970)
            let request = try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/world/\(world)/\(timestamp)")
            return request.fetchJSONAsync(as: MinecraftDynmapWorld.self)
        }
    }
}
