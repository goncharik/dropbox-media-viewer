import Combine
import Dependencies
import UIKit
import IdentifiedCollections

@MainActor
final class HomeViewModel: ObservableObject {
    enum NavigationEvents: Equatable {
        case logout
        case openFile(FileEntry)
    }

    @Dependency(\.authClient) private var authClient
    @Dependency(\.fileEntryRepo) private var fileEntryRepo
    @Dependency(\.contentClient) private var contentClient

    private let navHandler: @MainActor (NavigationEvents) -> Void

    @Published private(set) var isRefreshing = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var items: IdentifiedArrayOf<FileEntry> = []

    @Published var error: Error?

    init(
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.navHandler = navHandler

        fileEntryRepo.filesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }

    func load() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await fileEntryRepo.reload()
        } catch {
            self.error = error
        }
    }

    func loadMoreIfNeeded(for item: FileEntry) async {
        guard items.last?.id == item.id else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            try await fileEntryRepo.loadMoreIfNeeded()
        } catch {
            self.error = error
        }
    }

    func itemSelected(_ item: FileEntry) {
        navHandler(.openFile(item))
    }

    func logout() async {
        await authClient.logout()
        contentClient.clearCaches()
        navHandler(.logout)
    }

    func clearCaches() {
        contentClient.clearCaches()
    }

    func thumbnailProvider(_ item: FileEntry) -> () async -> UIImage? {
        return { [weak self] in
            do {
                return try await self?.contentClient.thumbnail(for: item)
            } catch {
                print("Error loading thumbnail:", error)
                return nil
            }
        }
    }
}
