import Foundation

struct FileEntry: Hashable, Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case tag = ".tag"
        case name
        case pathLower
        case pathDisplay
        case id
        case clientModified
        case serverModified
        case rev
        case size
        case isDownloadable
        case contentHash
    }

    enum Tag: String, Decodable {
        case file
        case folder
    }

    let tag: Tag
    let name: String
    let pathLower: String
    let pathDisplay: String
    let id: String
    let clientModified: Date?
    let serverModified: Date?
    let rev: String?
    let size: Int?
    let isDownloadable: Bool?
    let contentHash: String?
}

// MARK: - Helpers

extension FileEntry {
    var isFolder: Bool {
        tag == .folder
    }

    var isImage: Bool {
        guard !isFolder else { return false }
        return name.hasSuffix(".png")
            || name.hasSuffix(".jpg")
            || name.hasSuffix(".jpeg")
            || name.hasSuffix(".heic")
            || name.hasSuffix(".heif")
            || name.hasSuffix(".gif")
            || name.hasSuffix(".bmp")
    }

    var isVideo: Bool {
        guard !isFolder else { return false }
        return name.hasSuffix(".mp4")
            || name.hasSuffix(".m4v")
            || name.hasSuffix(".mov")
            || name.hasSuffix(".avi")
    }

    var ext: String? {
        name.components(separatedBy: ".").last
    }
}

// MARK: - Mocks and stubs

extension FileEntry {
    private static let fileEntityImageJson = """
    {
        ".tag": "file",
        "name": "me_art.png",
        "path_lower": "/photos/me_art.png",
        "path_display": "/Photos/me_art.png",
        "id": "id:01",
        "client_modified": "2015-11-10T09:39:39Z",
        "server_modified": "2023-08-27T05:58:46Z",
        "rev": "1",
        "size": 370742,
        "is_downloadable": true,
        "content_hash": "1"
    }
    """

    private static let fileEntityVideoJson = """
    {
        ".tag": "file",
        "name": "video.mp4",
        "path_lower": "/videos/video.mp4",
        "path_display": "/Videos/video.mp4",
        "id": "id:02",
        "client_modified": "2015-11-10T09:39:39Z",
        "server_modified": "2023-08-27T05:58:46Z",
        "rev": "2",
        "size": 10070742,
        "is_downloadable": true,
        "content_hash": "2"
    }
    """

    static let stubImage = try! JSONDecoder.default.decode(FileEntry.self, from: fileEntityImageJson.data(using: .utf8)!)
    static let stubVideo = try! JSONDecoder.default.decode(FileEntry.self, from: fileEntityVideoJson.data(using: .utf8)!)
}
