import Foundation

struct AppEnv {
    var clientId: String
    var clientSecret: String
    var baseUrl: String
    var oauthUrl: String
    var contentUrl: String
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
            contentUrl: "https://content.dropboxapi.com",
            defaultRedirectUri: "https://me.honcharenko.mediaviewer/auth"
        )
    }
}

// MARK: - Mock value

extension AppEnv {
    static var mock: Self {
        Self(
            clientId: "clientId",
            clientSecret: "clientSecret",
            baseUrl: "https://baseUrl",
            oauthUrl: "https://oauthUrl",
            contentUrl: "https://contentUrl",
            defaultRedirectUri: "https://defaultRedirectUri"
        )
    }
}
