import Foundation

struct AuthToken: Codable {
    var accessToken: String
    var tokenType: String
    var expiresIn: Int
    var uid: String?
    var accountId: String?
    var refreshToken: String?
    var createdAt: Date?

    var isValid: Bool {
        guard let createdAt else { return false }

        let now = Date()
        return createdAt.addingTimeInterval(TimeInterval(expiresIn)) > now
    }
}
