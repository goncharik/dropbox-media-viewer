import Combine
import Foundation
import IdentifiedCollections

struct Item: Identifiable {
    var id: UUID
}

import UIKit
@MainActor
final class HomeViewModel: ObservableObject  {
    enum NavigationEvents {
        case logout
    }

    struct Dependencies {
        var authClient: AuthClient
    }

    private let dependencies: Dependencies
    private let navHandler: @MainActor (NavigationEvents) -> Void

    @Published private(set) var isLoading = false
    @Published private(set) var items: IdentifiedArrayOf<Item> = [
        .init(id: UUID()),
        .init(id: UUID()),
        .init(id: UUID()),
    ]

    @Published var error: Error?    

    init(
        dependencies: Dependencies, 
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.dependencies = dependencies
        self.navHandler = navHandler

        let fileEntity = FileEntity.stub
        print(fileEntity)

//        let authSeesion = AuthSession(appEnv: .live, tokenStorage: KeychainTokenStorage(), httpClient: HTTPClientKey.liveValue)
//        fetchThumbnailForFile(file: fileMock, accessToken: authSeesion.accessToken()) { data, error in
//            if let error = error {
//                print("Thumbnail Fetch Error: \(error)")
//                return
//            }
//
//            if let thumbnailData = data {
//                print("got image thumb")
//                let image = UIImage(data: thumbnailData)
//                print(image)
//            }
//        }
    }

    func load() async {
        isLoading = true
        error = nil
        
        do {
            // ADD API CALL HERE
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func itemSelected(_ item: Item) {
        
    }

    func logout() async {
        await dependencies.authClient.logout()
        navHandler(.logout)
    }
}

// TODO: Remove after tests

let fileMock = """
{"format": "jpeg","mode": "fitone_bestfit","quality": "quality_80","resource": {".tag": "path","path": "/photos/me_art.png"},"size": "w64h64"}
"""
func fetchThumbnailForFile(file: String, accessToken: String, completion: @escaping (Data?, Error?) -> Void) {
    let thumbnailURLString = "https://content.dropboxapi.com/2/files/get_thumbnail_v2"
    let thumbnailURL = URL(string: thumbnailURLString)!

    var request = URLRequest(url: thumbnailURL)
    request.httpMethod = "GET"

    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.addValue(file, forHTTPHeaderField: "Dropbox-API-Arg")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }

        if let data = data {
            completion(data, nil)
        } else {
            completion(nil, NSError(domain: "EmptyResponse", code: -1, userInfo: nil))
        }
    }.resume()
}



