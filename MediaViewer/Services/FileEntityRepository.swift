import Combine
import Dependencies
import Foundation
import IdentifiedCollections


protocol FileEntityRepository {
    var files: IdentifiedArrayOf<FileEntity> { get }
    var filesPublisher: Published<IdentifiedArrayOf<FileEntity>>.Publisher { get }

    var isLoading: Bool { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }

    func reload() async throws
    func loadMoreIfNeeded() async throws
}

final class FileEntityRepositoryImpl: FileEntityRepository, ObservableObject {
    @Published var files: IdentifiedArrayOf<FileEntity> = []
    @Published var isLoading: Bool = false

    var filesPublisher: Published<IdentifiedArrayOf<FileEntity>>.Publisher { $files }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }

    private let apiClient: ApiClient

    private var cursor: String?
    private var hasMore: Bool = false

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func reload() async throws {
        guard !isLoading else { return }

        defer { isLoading = false }
        isLoading = true
        cursor = nil
        hasMore = false

        files = try await fetchMediaFiles(cursor)
    }

    func loadMoreIfNeeded() async throws {
        guard hasMore, let cursor, !isLoading else { return }

        defer { isLoading = false }
        isLoading = true

        let files = try await fetchMediaFiles(cursor)
        self.files.append(contentsOf: files)
    }

    // MARK: - Private helpers

    private func fetchMediaFiles(_ cursor: String?) async throws -> IdentifiedArrayOf<FileEntity> {
        let response: FileEntityListRespose
        if let cursor {
            response = try await apiClient.post(
                path: "/2/files/list_folder/continue",
                body: FileEntityListContinueRequest(cursor: cursor)
            )
        } else {
            response = try await apiClient.post(
                path: "/2/files/list_folder",
                body: FileEntityListRequest(path: "")
            )
        }

        self.cursor = response.cursor
        self.hasMore = response.hasMore

        return response.entities.filter {
            $0.isImage || $0.isVideo
        }
    }
}

// MARK: - Request/Response models

struct FileEntityListRequest: Encodable {
    var path: String
    var recursive: Bool = true
    var includeDeleted: Bool = false
}

struct FileEntityListContinueRequest: Encodable {
    var cursor: String
}

struct FileEntityListRespose: Decodable {
    let entities: IdentifiedArrayOf<FileEntity>
    let cursor: String?
    let hasMore: Bool
}

// MARK: - DI

extension DependencyValues {
    var fileEntityRepo: any FileEntityRepository {
        get { self[FileEntityRepositoryKey.self] }
        set { self[FileEntityRepositoryKey.self] = newValue }
    }
}

enum FileEntityRepositoryKey: DependencyKey {
    static var liveValue: any FileEntityRepository {
        @Dependency(\.apiClient) var apiClient

        return FileEntityRepositoryImpl(
            apiClient: apiClient
        )
    }
}
