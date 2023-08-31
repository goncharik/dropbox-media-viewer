import Combine
import Dependencies
import UIKit

@MainActor
@dynamicMemberLookup
final class DetailsViewModel: ObservableObject  {
    @Dependency(\.contentClient) private var contentClient

    private let file: FileEntry

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init(
        file: FileEntry
    ) {
        self.file = file
    }

    func contentImageProvider() -> () async -> UIImage? {
        return { [weak self] () -> UIImage? in
            guard let self else { return nil }
            do {
                return try await self.contentClient.fullsizeImage(for: self.file)
            } catch {
                self.error = error
                return nil
            }
        }
    }

    func contentVideoProvider() -> () async -> URL? {
        return { [weak self] () -> URL? in
            guard let self else { return nil }
            do {
                return try await self.contentClient.videoFileUrl(for: self.file)
            } catch {
                self.error = error
                return nil
            }
        }
    }

    // MARK: - @dynamicMemberLookup

    subscript<T>(dynamicMember keyPath: KeyPath<FileEntry, T>) -> T {
        file[keyPath: keyPath]
    }
}
