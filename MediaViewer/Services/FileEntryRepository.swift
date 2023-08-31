import Combine
import Dependencies
import Foundation
import IdentifiedCollections


protocol FileEntryRepository {
    var files: IdentifiedArrayOf<FileEntry> { get }
    var filesPublisher: Published<IdentifiedArrayOf<FileEntry>>.Publisher { get }

    var isLoading: Bool { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }

    func reload() async throws
    func loadMoreIfNeeded() async throws
}

final class FileEntryRepositoryImpl: FileEntryRepository, ObservableObject {
    @Published private(set) var files: IdentifiedArrayOf<FileEntry> = []
    @Published private(set) var isLoading: Bool = false

    var filesPublisher: Published<IdentifiedArrayOf<FileEntry>>.Publisher { $files }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }

    private let apiClient: ApiClient

    private var cursor: String?
    private var hasMore: Bool = false

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    @MainActor
    func reload() async throws {
        guard !isLoading else { return }

        defer { isLoading = false }
        isLoading = true
        cursor = nil
        hasMore = false

        files = try await fetchMediaFiles(cursor)
    }

    @MainActor
    func loadMoreIfNeeded() async throws {
        guard hasMore, let cursor, !isLoading else { return }

        defer { isLoading = false }
        isLoading = true

        let files = try await fetchMediaFiles(cursor)
        self.files.append(contentsOf: files)
    }

    // MARK: - Private helpers

    private func fetchMediaFiles(_ cursor: String?) async throws -> IdentifiedArrayOf<FileEntry> {
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

        let entries = response.entries.filter {
            $0.isImage || $0.isVideo
        }

        guard !entries.isEmpty else {
            // If this page doesn't have any media files, load the next page            
            if let cursor, hasMore {
                return try await fetchMediaFiles(cursor)
            } else {
                return []
            }
        }

        return entries
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
    let entries: IdentifiedArrayOf<FileEntry>
    let cursor: String?
    let hasMore: Bool
}

// MARK: - DI

extension DependencyValues {
    var fileEntryRepo: any FileEntryRepository {
        get { self[FileEntryRepositoryKey.self] }
        set { self[FileEntryRepositoryKey.self] = newValue }
    }
}

enum FileEntryRepositoryKey: DependencyKey {
    static var liveValue: any FileEntryRepository {
        @Dependency(\.apiClient) var apiClient

        return FileEntryRepositoryImpl(
            apiClient: apiClient
        )
    }
}
