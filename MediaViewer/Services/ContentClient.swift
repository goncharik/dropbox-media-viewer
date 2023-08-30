import Dependencies
import UIKit

protocol ContentClient {
    func thumbnail(for file: FileEntry) async throws -> UIImage?
    func fullsizeImage(for file: FileEntry) async throws -> UIImage?
    func cachedFileUrl(for file: FileEntry) async throws -> URL
}

final class ContentClientImpl: ContentClient {
    private let apiClient: ApiClient
    private let cache: DataCache

    init(apiClient: ApiClient, cache: DataCache) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func thumbnail(for file: FileEntry) async throws -> UIImage? {
        guard let image = cache.readImage(forKey: file.id) else {
            let thumbnailApiPath = "/2/files/get_thumbnail_v2"
            let data = try await apiClient.content(path: thumbnailApiPath, body: ThumbnailRequest(path: file.pathLower))
            cache.write(data: data, for: file.id)
            return UIImage(data: data)
        }

        return image
    }

    func fullsizeImage(for file: FileEntry) async throws -> UIImage? {
        fatalError("Not implemented")
    }

    func cachedFileUrl(for file: FileEntry) async throws -> URL {
        fatalError("Not implemented")
    }
}

// MARK: - DI

extension DependencyValues {
    var contentClient: any ContentClient {
        get { self[ContentClientKey.self] }
        set { self[ContentClientKey.self] = newValue }
    }
}

enum ContentClientKey: DependencyKey {
    static var liveValue: any ContentClient {
        @Dependency(\.apiClient) var apiClient
        @Dependency(\.dataCache) var cache

        return ContentClientImpl(apiClient: apiClient, cache: cache)
    }
}

