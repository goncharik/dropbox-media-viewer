import UIKit

// MARK: - ContentClientMock

final class ContentClientMock: ContentClient {
    
   // MARK: - thumbnail

    var thumbnailForThrowableError: Error?
    var thumbnailForCallsCount = 0
    var thumbnailForCalled: Bool {
        thumbnailForCallsCount > 0
    }
    var thumbnailForReceivedFile: FileEntry?
    var thumbnailForReceivedInvocations: [FileEntry] = []
    var thumbnailForReturnValue: UIImage?
    var thumbnailForClosure: ((FileEntry) throws -> UIImage?)?

    func thumbnail(for file: FileEntry) throws -> UIImage? {
        if let error = thumbnailForThrowableError {
            throw error
        }
        thumbnailForCallsCount += 1
        thumbnailForReceivedFile = file
        thumbnailForReceivedInvocations.append(file)
        return try thumbnailForClosure.map({ try $0(file) }) ?? thumbnailForReturnValue
    }
    
   // MARK: - fullsizeImage

    var fullsizeImageForThrowableError: Error?
    var fullsizeImageForCallsCount = 0
    var fullsizeImageForCalled: Bool {
        fullsizeImageForCallsCount > 0
    }
    var fullsizeImageForReceivedFile: FileEntry?
    var fullsizeImageForReceivedInvocations: [FileEntry] = []
    var fullsizeImageForReturnValue: UIImage?
    var fullsizeImageForClosure: ((FileEntry) throws -> UIImage?)?

    func fullsizeImage(for file: FileEntry) throws -> UIImage? {
        if let error = fullsizeImageForThrowableError {
            throw error
        }
        fullsizeImageForCallsCount += 1
        fullsizeImageForReceivedFile = file
        fullsizeImageForReceivedInvocations.append(file)
        return try fullsizeImageForClosure.map({ try $0(file) }) ?? fullsizeImageForReturnValue
    }
    
   // MARK: - videoFileUrl

    var videoFileUrlForThrowableError: Error?
    var videoFileUrlForCallsCount = 0
    var videoFileUrlForCalled: Bool {
        videoFileUrlForCallsCount > 0
    }
    var videoFileUrlForReceivedFile: FileEntry?
    var videoFileUrlForReceivedInvocations: [FileEntry] = []
    var videoFileUrlForReturnValue: URL?
    var videoFileUrlForClosure: ((FileEntry) throws -> URL?)?

    func videoFileUrl(for file: FileEntry) throws -> URL? {
        if let error = videoFileUrlForThrowableError {
            throw error
        }
        videoFileUrlForCallsCount += 1
        videoFileUrlForReceivedFile = file
        videoFileUrlForReceivedInvocations.append(file)
        return try videoFileUrlForClosure.map({ try $0(file) }) ?? videoFileUrlForReturnValue
    }
    
   // MARK: - clearCaches

    var clearCachesCallsCount = 0
    var clearCachesCalled: Bool {
        clearCachesCallsCount > 0
    }
    var clearCachesClosure: (() -> Void)?

    func clearCaches() {
        clearCachesCallsCount += 1
        clearCachesClosure?()
    }
}
