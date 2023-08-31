import Foundation
import IdentifiedCollections

// MARK: - FileEntryRepositoryMock

final class FileEntryRepositoryMock: FileEntryRepository {

    @Published var files: IdentifiedArrayOf<FileEntry> = []
    @Published var isLoading: Bool = false

    var filesPublisher: Published<IdentifiedArrayOf<FileEntry>>.Publisher { $files }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }


    // MARK: - reload

    var reloadThrowableError: Error?
    var reloadCallsCount = 0
    var reloadCalled: Bool {
        reloadCallsCount > 0
    }

    var reloadClosure: (() throws -> Void)?

    func reload() throws {
        if let error = reloadThrowableError {
            throw error
        }
        reloadCallsCount += 1
        try reloadClosure?()
    }

    // MARK: - loadMoreIfNeeded

    var loadMoreIfNeededThrowableError: Error?
    var loadMoreIfNeededCallsCount = 0
    var loadMoreIfNeededCalled: Bool {
        loadMoreIfNeededCallsCount > 0
    }

    var loadMoreIfNeededClosure: (() throws -> Void)?

    func loadMoreIfNeeded() throws {
        if let error = loadMoreIfNeededThrowableError {
            throw error
        }
        loadMoreIfNeededCallsCount += 1
        try loadMoreIfNeededClosure?()
    }
}
