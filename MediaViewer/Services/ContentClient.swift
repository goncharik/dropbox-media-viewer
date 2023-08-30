import Dependencies
import UIKit

enum ContentClientError: Error {
    case contentIsNotImage
    case contentIsNotVideo
}

protocol ContentClient {
    func thumbnail(for file: FileEntry) async throws -> UIImage?
    func fullsizeImage(for file: FileEntry) async throws -> UIImage?
    func videoFileUrl(for file: FileEntry) async throws -> URL?

    func clearCaches()
}

final class ContentClientImpl: ContentClient {
    private let apiClient: ApiClient
    private let cache: DataCache

    init(apiClient: ApiClient, cache: DataCache) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func thumbnail(for file: FileEntry) async throws -> UIImage? {
        let thumbnailId = "\(file.id)_thumbnail"
        guard let image = cache.readImage(forKey: thumbnailId) else {
            let apiPath = "/2/files/get_thumbnail_v2"
            let data = try await apiClient.content(path: apiPath, body: ThumbnailRequest(path: file.pathLower))
            cache.write(data: data, for: thumbnailId)
            print("Thumbnail from network")
            return UIImage(data: data)
        }

        print("Thumbnail from cache")
        return image
    }

    func fullsizeImage(for file: FileEntry) async throws -> UIImage? {
        guard file.isImage else { throw ContentClientError.contentIsNotImage }
        
        let contentId = "\(file.id)_content"
        guard let image = cache.readImage(forKey: contentId) else {
            let apiPath = "/2/files/download"
            let data = try await apiClient.content(path: apiPath, body: DownloadRequest(path: file.id))
            cache.write(data: data, for: contentId)
            print("Fullsize image from network")
            return UIImage(data: data)
        }

        print("Fullsize image from cache")
        return image
    }

    func videoFileUrl(for file: FileEntry) async throws -> URL? {
        guard file.isVideo else { throw ContentClientError.contentIsNotVideo }

        let contentId = "\(file.id)_content"
        guard let url = cache.cachedUrl(for: contentId, ext: file.ext) else {
            let apiPath = "/2/files/download"
            let url = try await apiClient.contentDownload(path: apiPath, body: DownloadRequest(path: file.id)) { [weak self] in
                self?.cache.store(url: $0, for: contentId, ext: file.ext)
            }
            print("File url from network")
            print("url:", url)
            return url
        }

        print("File url from cache")
        print("url:", url)
        return url
    }

    func clearCaches() {
        cache.cleanAll()
    }
}

// MARK: Request/Response models

struct DownloadRequest: Encodable {
    var path: String // may be path or id of FileEntry
}

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

