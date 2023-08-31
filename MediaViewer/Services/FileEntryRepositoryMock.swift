import Foundation
import IdentifiedCollections

// MARK: - FileEntryRepositoryMock

final class FileEntryRepositoryMock: FileEntryRepository {
    // MARK: - files

    var files: IdentifiedArrayOf<FileEntry> {
        get { underlyingFiles }
        set(value) { underlyingFiles = value }
    }

    private var underlyingFiles: IdentifiedArrayOf<FileEntry>!

    // MARK: - filesPublisher

    var filesPublisher: Published<IdentifiedArrayOf<FileEntry>>.Publisher {
        get { underlyingFilesPublisher }
        set(value) { underlyingFilesPublisher = value }
    }

    private var underlyingFilesPublisher: Published<IdentifiedArrayOf<FileEntry>>.Publisher!

    // MARK: - isLoading

    var isLoading: Bool {
        get { underlyingIsLoading }
        set(value) { underlyingIsLoading = value }
    }

    private var underlyingIsLoading: Bool!

    // MARK: - isLoadingPublisher

    var isLoadingPublisher: Published<Bool>.Publisher {
        get { underlyingIsLoadingPublisher }
        set(value) { underlyingIsLoadingPublisher = value }
    }

    private var underlyingIsLoadingPublisher: Published<Bool>.Publisher!

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
