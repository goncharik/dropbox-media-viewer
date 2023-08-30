import Dependencies
import UIKit

protocol DataCache {
    func write(data: Data, for key: String)
    func readData(for key: String) -> Data?
    func hasData(for key: String) -> Bool
    func cleanAll()
    func clean(for key: String)
}

final class DataCacheImpl: DataCache {
    private static let cacheDirectoryName = "me.honcharenko.mediaviewer.datacache"
    private static let ioQueueName = "me.honcharenko.mediaviewer.cache.queue"
    private static let defaultMaxCachePeriodInSecond: TimeInterval = 60 * 60 * 24 * 7 // one week

    private let cachePath: String

    private let memCache = NSCache<AnyObject, AnyObject>()
    private let ioQueue: DispatchQueue
    private let fileManager: FileManager

    /// Life time of disk cache, in second. Default is a week
    var maxCachePeriodInSecond = DataCacheImpl.defaultMaxCachePeriodInSecond

    /// Size is allocated for disk cache, in byte. 0 mean no limit. Default is 0
    var maxDiskCacheSize: UInt = 0

    init(path: String? = nil) {
        var cachePath = path ?? NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        cachePath = (cachePath as NSString).appendingPathComponent(Self.cacheDirectoryName)
        self.cachePath = cachePath

        ioQueue = DispatchQueue(label: Self.ioQueueName)

        fileManager = FileManager()

        NotificationCenter.default.addObserver(self, selector: #selector(cleanExpiredDiskCache), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cleanExpiredDiskCache), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Write data

    func write(data: Data, for key: String) {
        memCache.setObject(data as AnyObject, forKey: key as AnyObject)
        writeDataToDisk(data: data, key: key)
    }

    private func writeDataToDisk(data: Data, key: String) {
        ioQueue.async {
            if self.fileManager.fileExists(atPath: self.cachePath) == false {
                do {
                    try self.fileManager.createDirectory(atPath: self.cachePath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("DataCache: Error while creating cache folder: \(error.localizedDescription)")
                }
            }

            self.fileManager.createFile(atPath: self.cachePath(forKey: key), contents: data, attributes: nil)
        }
    }

    // MARK: - Read data

    func readData(for key: String) -> Data? {
        var data = memCache.object(forKey: key as AnyObject) as? Data

        if data == nil {
            if let dataFromDisk = readDataFromDisk(key) {
                data = dataFromDisk
                memCache.setObject(dataFromDisk as AnyObject, forKey: key as AnyObject)
            }
        }

        return data
    }

    private func readDataFromDisk(_ key: String) -> Data? {
        fileManager.contents(atPath: cachePath(forKey: key))
    }

    // MARK: - Check data

    func hasData(for key: String) -> Bool {
        hasDataOnDisk(forKey: key) || hasDataOnMem(forKey: key)
    }

    private func hasDataOnDisk(forKey key: String) -> Bool {
        fileManager.fileExists(atPath: cachePath(forKey: key))
    }

    private func hasDataOnMem(forKey key: String) -> Bool {
        memCache.object(forKey: key as AnyObject) != nil
    }

    // MARK: - Clean

    func cleanAll() {
        cleanMemCache()
        cleanDiskCache()
    }

    func clean(for key: String) {
        memCache.removeObject(forKey: key as AnyObject)

        ioQueue.async {
            do {
                try self.fileManager.removeItem(atPath: self.cachePath(forKey: key))
            } catch {
                print("DataCache: Error while remove file: \(error.localizedDescription)")
            }
        }
    }

    private func cleanMemCache() {
        memCache.removeAllObjects()
    }

    private func cleanDiskCache() {
        ioQueue.async {
            do {
                try self.fileManager.removeItem(atPath: self.cachePath)
            } catch {
                print("DataCache: Error when clean disk: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UIImage helpers

extension DataCache {
    func write(image: UIImage, forKey key: String) {
        let data = image.jpegData(compressionQuality: 0.9)

        if let data {
            write(data: data, for: key)
        }
    }

    func readImage(forKey key: String) -> UIImage? {
        let data = readData(for: key)
        if let data {
            return UIImage(data: data, scale: 1.0)
        }

        return nil
    }
}

// MARK: - Helpers from Kingfisher

extension DataCacheImpl {
    @objc private func cleanExpiredDiskCache() {
        cleanExpiredDiskCache(completion: nil)
    }

    private func cleanExpiredDiskCache(completion handler: (() -> Void)? = nil) {
        ioQueue.async {
            var (URLsToDelete, diskCacheSize, cachedFiles) = self.travelCachedFiles(onlyForCacheSize: false)

            for fileURL in URLsToDelete {
                do {
                    try self.fileManager.removeItem(at: fileURL)
                } catch {
                    print("Cache: Error while removing files \(error.localizedDescription)")
                }
            }

            if self.maxDiskCacheSize > 0, diskCacheSize > self.maxDiskCacheSize {
                let targetSize = self.maxDiskCacheSize / 2

                // Sort files by last modify date. We want to clean from the oldest files.
                let sortedFiles = cachedFiles.keysSortedByValue {
                    resourceValue1, resourceValue2 -> Bool in

                    if let date1 = resourceValue1.contentAccessDate,
                       let date2 = resourceValue2.contentAccessDate
                    {
                        return date1.compare(date2) == .orderedAscending
                    }

                    // Not valid date information. This should not happen. Just in case.
                    return true
                }

                for fileURL in sortedFiles {
                    do {
                        try self.fileManager.removeItem(at: fileURL)
                    } catch {
                        print("Cache: Error while removing files \(error.localizedDescription)")
                    }

                    URLsToDelete.append(fileURL)

                    if let fileSize = cachedFiles[fileURL]?.totalFileAllocatedSize {
                        diskCacheSize -= UInt(fileSize)
                    }

                    if diskCacheSize < targetSize {
                        break
                    }
                }
            }

            DispatchQueue.main.async { () in
                handler?()
            }
        }
    }

    private func travelCachedFiles(onlyForCacheSize: Bool) -> (urlsToDelete: [URL], diskCacheSize: UInt, cachedFiles: [URL: URLResourceValues]) {
        let diskCacheURL = URL(fileURLWithPath: cachePath)
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        let expiredDate: Date? = (maxCachePeriodInSecond < 0) ? nil : Date(timeIntervalSinceNow: -maxCachePeriodInSecond)

        var cachedFiles = [URL: URLResourceValues]()
        var urlsToDelete = [URL]()
        var diskCacheSize: UInt = 0

        for fileUrl in (try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? [] {
            do {
                let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }

                // If this file is expired, add it to URLsToDelete
                if !onlyForCacheSize,
                   let expiredDate,
                   let lastAccessData = resourceValues.contentAccessDate,
                   (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate
                {
                    urlsToDelete.append(fileUrl)
                    continue
                }

                if let fileSize = resourceValues.totalFileAllocatedSize {
                    diskCacheSize += UInt(fileSize)
                    if !onlyForCacheSize {
                        cachedFiles[fileUrl] = resourceValues
                    }
                }
            } catch {
                print("DataCache: Error while iterating files \(error.localizedDescription)")
            }
        }

        return (urlsToDelete, diskCacheSize, cachedFiles)
    }

    private func cachePath(forKey key: String) -> String {
        let fileName = key.md5
        return (cachePath as NSString).appendingPathComponent(fileName)
    }
}

extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore: (Value, Value) -> Bool) -> [Key] {
        Array(self).sorted { isOrderedBefore($0.1, $1.1) }.map(\.0)
    }
}

// MARK: - DI

extension DependencyValues {
    var dataCache: any DataCache {
        get { self[DataCacheKey.self] }
        set { self[DataCacheKey.self] = newValue }
    }
}

enum DataCacheKey: DependencyKey {
    static var liveValue: any DataCache {
        DataCacheImpl()
    }
}
