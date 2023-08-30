import Combine
import Foundation
import IdentifiedCollections

@MainActor
final class HomeViewModel: ObservableObject {
    enum NavigationEvents {
        case logout
        case openFile(FileEntry)
    }

    struct Dependencies {
        var authClient: AuthClient
        var fileEntryRepo: FileEntryRepository
    }

    private let dependencies: Dependencies
    private let navHandler: @MainActor (NavigationEvents) -> Void

    @Published private(set) var isRefreshing = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var items: IdentifiedArrayOf<FileEntry> = [
        .stub,
    ]

    @Published var error: Error?

    init(
        dependencies: Dependencies,
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.dependencies = dependencies
        self.navHandler = navHandler

        dependencies.fileEntryRepo.filesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)

//        Task {
//            do {
//                let string = try ThumbnailRequest(path: fileMock).toJsonString()
//                print("json string:", string)
//
//                let data = try await fetchThumbnailForFile(path: fileMock)
//                print("got image thumb")
//                let image = UIImage(data: data)
//                print(image)
//            } catch {
//                print("Thumbnail Fetch Error: \(error)")
//            }
//        }
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
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await dependencies.fileEntryRepo.reload()
        } catch {
            self.error = error
        }
    }

    func loadMoreIfNeeded(_ item: FileEntry) async {
        guard items.last?.id == item.id else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            try await dependencies.fileEntryRepo.loadMoreIfNeeded()
        } catch {
            self.error = error
        }
    }

    func itemSelected(_ item: FileEntry) {
        navHandler(.openFile(item))
    }

    func logout() async {
        await dependencies.authClient.logout()
        navHandler(.logout)
    }
}

// TODO: Remove after tests

struct ThumbnailRequest: Encodable {
    var format: String = "jpeg"
    var mode: String = "fitone_bestfit"
    var quality: String = "quality_80"
    var resource: Resource
    var size: String = "w64h64"

    struct Resource: Encodable {
        enum CodingKeys: String, CodingKey {
            case tag = ".tag"
            case path
        }

        var tag: String = "path"
        var path: String
    }

    init(path: String) {
        resource = Resource(path: path)
    }
}

let fileMock = "/photos/me_art.png"
func fetchThumbnailForFile(path: String) async throws -> Data {
    let appEnv = AppEnv.live
    let apiClient: ApiClient = ApiClientKey.liveValue

    let thumbnailApiPath = "/2/files/get_thumbnail_v2"
    return try await apiClient.content(path: thumbnailApiPath, body: ThumbnailRequest(path: path))
}

