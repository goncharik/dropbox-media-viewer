import Combine
import Dependencies
import UIKit

@MainActor
@dynamicMemberLookup
final class DetailsViewModel: ObservableObject  {
    enum NavigationEvents {
        case back
    }

    @Dependency(\.contentClient) private var contentClient
    private let navHandler: @MainActor (NavigationEvents) -> Void
    
    private let file: FileEntry

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init(
        file: FileEntry,
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.file = file
        self.navHandler = navHandler
    }

    func back() {
        navHandler(.back)
    }

    func contentImageProvider() -> () async throws -> UIImage? {
        return { [weak self] () -> UIImage? in
            guard let self else { return nil }
            return try await self.contentClient.fullsizeImage(for: self.file)
        }
    }

    func contentVideoProvider() -> () async throws -> URL? {
        return { [weak self] () -> URL? in
            guard let self else { return nil }
            return try await self.contentClient.videoFileUrl(for: self.file)
        }
    }

    // MARK: - @dynamicMemberLookup

    subscript<T>(dynamicMember keyPath: KeyPath<FileEntry, T>) -> T {
        file[keyPath: keyPath]
    }
}
