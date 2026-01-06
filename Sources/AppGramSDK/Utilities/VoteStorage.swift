import Foundation

/// Manages local persistence of user votes using UserDefaults.
internal final class VoteStorage: Sendable {
    private static let votedWishesKey = "appgram_voted_wishes"

    static let shared = VoteStorage()

    private init() {}

    /// Returns the set of wish IDs the user has voted on.
    func getVotedWishIds() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: Self.votedWishesKey) ?? []
        return Set(array)
    }

    /// Checks if the user has voted on a specific wish.
    func hasVoted(wishId: String) -> Bool {
        getVotedWishIds().contains(wishId)
    }

    /// Marks a wish as voted.
    func addVote(wishId: String) {
        var votedIds = getVotedWishIds()
        votedIds.insert(wishId)
        UserDefaults.standard.set(Array(votedIds), forKey: Self.votedWishesKey)
    }

    /// Removes a vote from a wish.
    func removeVote(wishId: String) {
        var votedIds = getVotedWishIds()
        votedIds.remove(wishId)
        UserDefaults.standard.set(Array(votedIds), forKey: Self.votedWishesKey)
    }

    /// Applies stored vote state to an array of wishes.
    func applyVoteState(to wishes: inout [Wish]) {
        let votedIds = getVotedWishIds()
        for index in wishes.indices {
            wishes[index].hasVoted = votedIds.contains(wishes[index].id)
        }
    }

    /// Applies stored vote state to a single wish.
    func applyVoteState(to wish: inout Wish) {
        wish.hasVoted = hasVoted(wishId: wish.id)
    }
}
