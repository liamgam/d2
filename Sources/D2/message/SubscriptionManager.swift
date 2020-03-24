import SwiftDiscord
import D2Commands

class SubscriptionManager {
    private var subscriptionSets: [String: SubscriptionSet] = [:]
    var isEmpty: Bool { subscriptionSets.isEmpty }
    
    func createIfNotExistsAndGetSubscriptionSet(for commandName: String) -> SubscriptionSet {
        var subscriptionSet = subscriptionSets[commandName]
        if subscriptionSet == nil {
            subscriptionSet = SubscriptionSet()
            subscriptionSets[commandName] = subscriptionSet
        }
        return subscriptionSet!
    }

    func hasSubscription(on channel: ChannelID, by commandName: String) -> Bool {
        subscriptionSets[commandName]?.contains(channel) ?? false
    }
    
    func notifySubscriptions(on channel: ChannelID, isBot: Bool, action: (String, SubscriptionSet) -> Void) {
        guard !isBot else { return } // TODO: Respect the command's userOnly setting here for more fine-grained bot filtering
        for (commandName, subscriptionSet) in subscriptionSets {
            if subscriptionSet.contains(channel) {
                action(commandName, subscriptionSet)
            }
        }
    }
}
