import Foundation

struct AppEnv {
    var clientId: String
    var clientSecret: String
    var baseUrl: String
    var oauthUrl: String
    var defaultRedirectUri: String
}

// MARK: - Live value

extension AppEnv {
    static var live: Self {
        Self(
            clientId: "empty-client-id",
            clientSecret: "empty-client-secret",
            baseUrl: "https://api.dropboxapi.com",
            oauthUrl: "https://www.dropbox.com/oauth2/authorize",
            defaultRedirectUri: "https://me.honcharenko.mediaviewer/auth"
        )
    }
}
