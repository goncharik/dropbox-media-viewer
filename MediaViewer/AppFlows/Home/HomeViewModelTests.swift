import Dependencies
import Combine
import XCTest

@testable import MediaViewer

@MainActor
final class HomeViewModelTests: XCTestCase {
    enum TestError: Error { case test }

    var sut: HomeViewModel!
    var fileEntryRepoMock: FileEntryRepositoryMock!
    var authClientMock: AuthClientMock!
    var contentClientMock: ContentClientMock!

    var receivedNavEvent: HomeViewModel.NavigationEvents!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        fileEntryRepoMock = FileEntryRepositoryMock()
        authClientMock = AuthClientMock()
        contentClientMock = ContentClientMock()
        sut = withDependencies({
            $0.authClient = authClientMock
            $0.fileEntryRepo = fileEntryRepoMock
            $0.contentClient = contentClientMock
        }, operation: {
            HomeViewModel(navHandler: { self.receivedNavEvent = $0 })
        })
    }

    override func tearDownWithError() throws {
        sut = nil
        fileEntryRepoMock = nil
        authClientMock = nil
        contentClientMock = nil
        receivedNavEvent = nil
        cancellables = []
        try super.tearDownWithError()
    }

    func testIsRefreshingLoadSuccess() async {
        // Given
        var isRefreshingSequence: [Bool] = []
        var isLoadingMoreSequence: [Bool] = []
        sut.$isRefreshing
            .sink { isRefreshingSequence.append($0) }
            .store(in: &cancellables)
        sut.$isLoadingMore
            .sink { isLoadingMoreSequence.append($0) }
            .store(in: &cancellables)
        fileEntryRepoMock.reloadClosure = { [weak fileEntryRepoMock] in
            fileEntryRepoMock?.files = [.stubImage]
        }
        // When
        let expectation = XCTestExpectation(description: "contentLoaded")
        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        await sut.load()
        await fulfillment(of: [expectation], timeout: 0.1)

        // Then
        XCTAssertEqual(isRefreshingSequence, [false, true, false])
        XCTAssertEqual(isLoadingMoreSequence, [false])
        XCTAssertEqual(fileEntryRepoMock.reloadCallsCount, 1)
        XCTAssertEqual(sut.items, [.stubImage])
        XCTAssertNil(sut.error)
    }

    func testIsRefreshingLoadError() async {
        // Given
        fileEntryRepoMock.reloadThrowableError = TestError.test
        var isRefreshingSequence: [Bool] = []
        var isLoadingMoreSequence: [Bool] = []
        sut.$isRefreshing
            .sink { isRefreshingSequence.append($0) }
            .store(in: &cancellables)
        sut.$isLoadingMore
            .sink { isLoadingMoreSequence.append($0) }
            .store(in: &cancellables)

        // When
        await sut.load()

        // Then
        XCTAssertEqual(isRefreshingSequence, [false, true, false])
        XCTAssertEqual(isLoadingMoreSequence, [false])
        XCTAssertEqual(sut.error as! TestError, TestError.test)
    }

    func testIsLoadingMoreOnLoadMoreForLastItemSuccess() async {
        // Given
        let expectationSetup = XCTestExpectation(description: "bindingItems")
        let expectationLoad = XCTestExpectation(description: "contentLoaded")
        var itemsTriggerCount = 0
        sut.$items
            .dropFirst()
            .sink { _ in
                if itemsTriggerCount == 0 {
                    expectationSetup.fulfill()
                }
                if itemsTriggerCount == 1 {
                    expectationLoad.fulfill()
                }
                itemsTriggerCount += 1
            }
            .store(in: &cancellables)
        fileEntryRepoMock.files = [.stubImage]
        var isRefreshingSequence: [Bool] = []
        var isLoadingMoreSequence: [Bool] = []
        sut.$isRefreshing
            .sink { isRefreshingSequence.append($0) }
            .store(in: &cancellables)
        sut.$isLoadingMore
            .sink { isLoadingMoreSequence.append($0) }
            .store(in: &cancellables)
        fileEntryRepoMock.loadMoreIfNeededClosure = { [weak fileEntryRepoMock] in
            fileEntryRepoMock?.files = [.stubImage, .stubVideo]
        }

        // When
        await fulfillment(of: [expectationSetup], timeout: 0.1)
        await sut.loadMoreIfNeeded(for: .stubImage)
        await fulfillment(of: [expectationLoad], timeout: 0.1)

        // Then
        XCTAssertEqual(isRefreshingSequence, [false])
        XCTAssertEqual(isLoadingMoreSequence, [false, true, false])
        XCTAssertEqual(fileEntryRepoMock.loadMoreIfNeededCallsCount, 1)
        XCTAssertEqual(sut.items, [.stubImage, .stubVideo])
        XCTAssertNil(sut.error)
    }

    func testNoLoadingMoreOnLoadMoreForNonLastItem() async {
        // Given
        let expectation = XCTestExpectation(description: "bindingItems")
        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        fileEntryRepoMock.files = [.stubImage, .stubVideo]
        var isRefreshingSequence: [Bool] = []
        var isLoadingMoreSequence: [Bool] = []
        sut.$isRefreshing
            .sink { isRefreshingSequence.append($0) }
            .store(in: &cancellables)
        sut.$isLoadingMore
            .sink { isLoadingMoreSequence.append($0) }
            .store(in: &cancellables)

        // When
        await fulfillment(of: [expectation], timeout: 0.1)
        await sut.loadMoreIfNeeded(for: .stubImage)

        // Then
        XCTAssertEqual(isRefreshingSequence, [false])
        XCTAssertEqual(isLoadingMoreSequence, [false])
        XCTAssertEqual(fileEntryRepoMock.loadMoreIfNeededCallsCount, 0)
        XCTAssertNil(sut.error)
    }

    func testErrorOnLoadMoreWithError() async {
        // Given
        let expectation = XCTestExpectation(description: "bindingItems")
        sut.$items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        fileEntryRepoMock.files = [.stubImage]
        fileEntryRepoMock.loadMoreIfNeededThrowableError = TestError.test
        var isRefreshingSequence: [Bool] = []
        var isLoadingMoreSequence: [Bool] = []
        sut.$isRefreshing
            .sink { isRefreshingSequence.append($0) }
            .store(in: &cancellables)
        sut.$isLoadingMore
            .sink { isLoadingMoreSequence.append($0) }
            .store(in: &cancellables)

        // When
        await fulfillment(of: [expectation], timeout: 0.1)
        await sut.loadMoreIfNeeded(for: .stubImage)

        // Then
        XCTAssertEqual(isRefreshingSequence, [false])
        XCTAssertEqual(isLoadingMoreSequence, [false, true, false])
        XCTAssertEqual(sut.error as! TestError, TestError.test)
    }

    func testItemSelectionNavigation() {
        // Given
        let item = FileEntry.stubImage

        // When
        sut.itemSelected(item)

        // Then
        XCTAssertEqual(receivedNavEvent, .openFile(item))
    }

    func testLogout() async {
        // Given

        // When
        await sut.logout()

        // Then
        XCTAssertEqual(authClientMock.logoutCallsCount, 1)
        XCTAssertEqual(contentClientMock.clearCachesCallsCount, 1)
        XCTAssertEqual(receivedNavEvent, .logout)
    }

    func testClearCache() {
        // When
        sut.clearCaches()

        // Then
        XCTAssertEqual(contentClientMock.clearCachesCallsCount, 1)        
    }
}
