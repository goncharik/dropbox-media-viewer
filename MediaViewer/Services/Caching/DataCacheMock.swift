import Foundation

// MARK: - DataCacheMock

final class DataCacheMock: DataCache {

    // MARK: - store

    var storeUrlForExtCallsCount = 0
    var storeUrlForExtCalled: Bool {
        storeUrlForExtCallsCount > 0
    }
    var storeUrlForExtReceivedArguments: (url: URL, key: String, ext: String?)?
    var storeUrlForExtReceivedInvocations: [(url: URL, key: String, ext: String?)] = []
    var storeUrlForExtReturnValue: URL?
    var storeUrlForExtClosure: ((URL, String, String?) -> URL?)?

    func store(url: URL, for key: String, ext: String?) -> URL? {
        storeUrlForExtCallsCount += 1
        storeUrlForExtReceivedArguments = (url: url, key: key, ext: ext)
        storeUrlForExtReceivedInvocations.append((url: url, key: key, ext: ext))
        return storeUrlForExtClosure.map({ $0(url, key, ext) }) ?? storeUrlForExtReturnValue
    }

    // MARK: - cachedUrl

    var cachedUrlForExtCallsCount = 0
    var cachedUrlForExtCalled: Bool {
        cachedUrlForExtCallsCount > 0
    }
    var cachedUrlForExtReceivedArguments: (key: String, ext: String?)?
    var cachedUrlForExtReceivedInvocations: [(key: String, ext: String?)] = []
    var cachedUrlForExtReturnValue: URL?
    var cachedUrlForExtClosure: ((String, String?) -> URL?)?

    func cachedUrl(for key: String, ext: String?) -> URL? {
        cachedUrlForExtCallsCount += 1
        cachedUrlForExtReceivedArguments = (key: key, ext: ext)
        cachedUrlForExtReceivedInvocations.append((key: key, ext: ext))
        return cachedUrlForExtClosure.map({ $0(key, ext) }) ?? cachedUrlForExtReturnValue
    }

    // MARK: - write

    var writeDataForCallsCount = 0
    var writeDataForCalled: Bool {
        writeDataForCallsCount > 0
    }
    var writeDataForReceivedArguments: (data: Data, key: String)?
    var writeDataForReceivedInvocations: [(data: Data, key: String)] = []
    var writeDataForClosure: ((Data, String) -> Void)?

    func write(data: Data, for key: String) {
        writeDataForCallsCount += 1
        writeDataForReceivedArguments = (data: data, key: key)
        writeDataForReceivedInvocations.append((data: data, key: key))
        writeDataForClosure?(data, key)
    }

    // MARK: - readData

    var readDataForCallsCount = 0
    var readDataForCalled: Bool {
        readDataForCallsCount > 0
    }
    var readDataForReceivedKey: String?
    var readDataForReceivedInvocations: [String] = []
    var readDataForReturnValue: Data?
    var readDataForClosure: ((String) -> Data?)?

    func readData(for key: String) -> Data? {
        readDataForCallsCount += 1
        readDataForReceivedKey = key
        readDataForReceivedInvocations.append(key)
        return readDataForClosure.map({ $0(key) }) ?? readDataForReturnValue
    }

    // MARK: - hasData

    var hasDataForCallsCount = 0
    var hasDataForCalled: Bool {
        hasDataForCallsCount > 0
    }
    var hasDataForReceivedKey: String?
    var hasDataForReceivedInvocations: [String] = []
    var hasDataForReturnValue: Bool!
    var hasDataForClosure: ((String) -> Bool)?

    func hasData(for key: String) -> Bool {
        hasDataForCallsCount += 1
        hasDataForReceivedKey = key
        hasDataForReceivedInvocations.append(key)
        return hasDataForClosure.map({ $0(key) }) ?? hasDataForReturnValue
    }

    // MARK: - cleanAll

    var cleanAllCallsCount = 0
    var cleanAllCalled: Bool {
        cleanAllCallsCount > 0
    }
    var cleanAllClosure: (() -> Void)?

    func cleanAll() {
        cleanAllCallsCount += 1
        cleanAllClosure?()
    }

    // MARK: - clean

    var cleanForCallsCount = 0
    var cleanForCalled: Bool {
        cleanForCallsCount > 0
    }
    var cleanForReceivedKey: String?
    var cleanForReceivedInvocations: [String] = []
    var cleanForClosure: ((String) -> Void)?

    func clean(for key: String) {
        cleanForCallsCount += 1
        cleanForReceivedKey = key
        cleanForReceivedInvocations.append(key)
        cleanForClosure?(key)
    }
}
