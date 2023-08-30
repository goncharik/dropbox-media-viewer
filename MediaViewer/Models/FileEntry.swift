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
}

// MARK: - Mocks and stubs

extension FileEntry {
    private static let fileEntityJson = """
    {
        ".tag": "file",
        "name": "me_art.png",
        "path_lower": "/photos/me_art.png",
        "path_display": "/Photos/me_art.png",
        "id": "id:t37-BDMYveAAAAAAAAAAAQ",
        "client_modified": "2015-11-10T09:39:39Z",
        "server_modified": "2023-08-27T05:58:46Z",
        "rev": "01603e1456027f6000000010a443011",
        "size": 370742,
        "is_downloadable": true,
        "content_hash": "68a97ad6ce5c86f8146ad305bc53fe4c51f638ad7838921de181e5b9b1b08a1d"
    }
    """

    static let stub = try! JSONDecoder.default.decode(FileEntry.self, from: fileEntityJson.data(using: .utf8)!)
}
