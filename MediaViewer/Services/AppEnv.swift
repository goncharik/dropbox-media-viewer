import Foundation

struct AppEnv {
    var clientId: String
    var clientSecret: String
    var baseUrl: String
    
    static func live() -> Self {
        Self(
            clientId: "empty-client-id",
            clientSecret: "empty-client-secret",
            baseUrl: "https://api.dropboxapi.com"
        )
    }
}
