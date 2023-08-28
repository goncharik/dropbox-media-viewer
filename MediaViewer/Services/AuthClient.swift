import Dependencies
import Foundation
import KeychainAccess

struct AuthClient {
    var defaultRedirectUri: String
    var oauthURL: () -> URL

    var signIn: (_ authCode: String) async throws -> Void
    var signOut: () -> Void
}

private let kAuthTokenKey = "kAuthTokenKey"

enum AuthError: Error {
    case missingToken
    case invalidToken
}

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

actor AuthSession {
    nonisolated private let currentToken: Isolated<AuthToken?>

    private var refreshTask: Task<AuthToken, Error>?

    private let appEnv: AppEnv
    private let keychain: Keychain

    init(appEnv: AppEnv, keychain: Keychain = Keychain(service: "com.honcharenko.mediaviewer")) {
        self.appEnv = appEnv
        self.keychain = keychain
        var token: AuthToken?
        if let data = try? keychain.getData(kAuthTokenKey) {
            token = try? decoder.decode(AuthToken.self, from: data)
        } 
        currentToken = Isolated(token, didSet: { _, newValue in
            if let data = try? encoder.encode(newValue) {
                try? keychain.set(data, key: kAuthTokenKey)
            }
        })
    }
    
    nonisolated func isAuthorized() -> Bool {
        return currentToken.value != nil
    }

    func validToken() async throws -> AuthToken {
        if let handle = refreshTask {
            return try await handle.value
        }

        guard let token = currentToken.value else {
            throw AuthError.missingToken
        }

        if token.isValid {
            print("Token is valid")
            return token
        }

        guard let refreshToken = token.refreshToken else {
            throw AuthError.missingToken
        }

        return try await self.refreshToken(with: refreshToken)
    }

    func refreshToken(with refreshToken: String) async throws -> AuthToken {
        if let refreshTask {
            return try await refreshTask.value
        }
        let task = Task { () throws -> AuthToken in
            defer { refreshTask = nil }
            print("Refreshing token...")
            
            let tokenURLString = appEnv.baseUrl + "/oauth2/token"
            guard let tokenURL = URL(string: tokenURLString) else {
                throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
            }

            var request = URLRequest(url: tokenURL)
            request.httpMethod = "POST"

            let bodyParameters = [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": appEnv.clientId,
                "client_secret": appEnv.clientSecret,
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                var newToken: AuthToken = try apiDecode(from: data)
                // Add missing data for refresh token response:
                newToken.refreshToken = refreshToken
                newToken.createdAt = Date()
                newToken.uid = currentToken.value?.uid
                newToken.accountId = currentToken.value?.accountId
                
                currentToken.value = newToken
                return newToken
            } catch {
                throw AuthError.invalidToken
            }
        }

        refreshTask = task

        return try await task.value
    }
    
    @discardableResult
    func obtainToken(for authorizationCode: String) async throws -> AuthToken {
        let clientID = appEnv.clientId
        let clientSecret = appEnv.clientSecret
        let redirectURI = AuthClient.liveValue.defaultRedirectUri
        let tokenURL = URL(string: appEnv.baseUrl + "/oauth2/token")!
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        let bodyParameters: [String: String] = [
            "grant_type": "authorization_code",
            "code": authorizationCode,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        
        let bodyData = bodyParameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        request.httpBody = bodyData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        var accessToken: AuthToken = try apiDecode(from: data)
        accessToken.createdAt = Date()
        currentToken.value = accessToken
        
        return accessToken
    }
    
    func logout() {
        currentToken.value = nil
    }
}

extension AuthClient: DependencyKey {
    static func live(appEnv: AppEnv) -> Self {
        let redirectUri = "https://me.honcharenko.mediaviewer/auth"
        return Self(
            defaultRedirectUri: redirectUri,
            oauthURL: {
                var components = URLComponents()
                components.scheme = "https"
                components.host = "www.dropbox.com"
                components.path = "/oauth2/authorize"

                components.queryItems = [
                    URLQueryItem(name: "client_id", value: appEnv.clientId),
                    URLQueryItem(name: "response_type", value: "code"),
                    URLQueryItem(name: "redirect_uri", value: redirectUri),
                    URLQueryItem(name: "token_access_type", value: "offline"),
                    URLQueryItem(name: "force_reapprove", value: "true"),
                    URLQueryItem(name: "disable_signup", value: "true"),
                ]

                return components.url!
            },
            signIn: { _ in
                
            },
            signOut: {
                // clear keychain
            }
        )
    }

    static var liveValue: AuthClient = .live(appEnv: .live())
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

struct ApiError: Error, Decodable {
    let error: String
    let errorDescription: String
}

func apiDecode<A: Decodable>(from data: Data) throws -> A {
    do {
        return try decoder.decode(A.self, from: data)
    } catch let decodingError {
        let apiError: Error
        do {
            apiError = try decoder.decode(ApiError.self, from: data)
        } catch {
            throw decodingError
        }
        throw apiError
    }
}

private let encoder = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()

private let decoder = { () -> JSONDecoder in
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()
