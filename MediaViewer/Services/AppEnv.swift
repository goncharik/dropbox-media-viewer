import Foundation

struct AppEnv {
    enum AppAuthType {
        case oauth(clientId: String, clientSecret: String)
        case accessToken(String)
    }

    var appAuthType: AppAuthType
    var baseUrl: String
    var oauthUrl: String
    var contentUrl: String
    var defaultRedirectUri: String

    var clientId: String? {
        switch appAuthType {
        case let .oauth(clientId, _):
            return clientId
        default:
            return nil
        }
    }

    var clientSecret: String? {
        switch appAuthType {
        case let .oauth(_, clientSecret):
            return clientSecret
        default:
            return nil
        }
    }

    var permanentToken: String? {
        switch appAuthType {
        case let .accessToken(token):
            return token
        default:
            return nil
        }
    }
}

// MARK: - Live value

extension AppEnv {
    static var live: Self {
        Self(
            appAuthType:
                    .accessToken("empty-access-token"),
//                    .oauth(
//                clientId: "empty-client-id",
//                clientSecret: "empty-client-secret"
//            ),
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
            appAuthType: .oauth(clientId: "clientId", clientSecret: "clientSecret"),
            baseUrl: "https://baseUrl",
            oauthUrl: "https://oauthUrl",
            contentUrl: "https://contentUrl",
            defaultRedirectUri: "https://defaultRedirectUri"
        )
    }
}
