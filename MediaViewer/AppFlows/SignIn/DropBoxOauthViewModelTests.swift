import Combine
import Dependencies
import XCTest

@testable import MediaViewer

@MainActor
final class DropBoxOauthViewModelTests: XCTestCase {
    enum TestError: Error { case test }

    var sut: DropBoxOauthViewModel!
    var authClientMock: AuthClientMock!
    var receivedNavEvent: DropBoxOauthViewModel.NavigationEvents!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        authClientMock = AuthClientMock()
        sut = withDependencies({
            $0.authClient = authClientMock
        }, operation: {
            DropBoxOauthViewModel(navHandler: { self.receivedNavEvent = $0 })
        })
    }

    override func tearDownWithError() throws {
        sut = nil
        authClientMock = nil
        receivedNavEvent = nil
        cancellables = []
        try super.tearDownWithError()
    }

    func testConfigurationSetup() throws {
        // Given
        let mockURL = URL(string: "https://example.com")!
        let mockRedirectUri = "https://example.com/redirect"
        authClientMock.oauthURLReturnValue = mockURL
        authClientMock.redirectUri = mockRedirectUri

        // When

        // Then
        XCTAssertEqual(sut.authUrl(), mockURL)
        XCTAssertEqual(sut.redirectUri(), mockRedirectUri)
    }

    func testProcessAuthCodeSuccess() async throws {
        // Given
        let mockCode = "mockCode"
        var isLoadingSequence: [Bool] = []
        sut.$isLoading
            .sink { isLoadingSequence.append($0) }
            .store(in: &cancellables)

        // When
        await sut.processAuthCode(mockCode)

        // Then
        XCTAssertEqual(isLoadingSequence, [false, true, false])
        XCTAssertNil(sut.error)
        XCTAssertEqual(receivedNavEvent, .signedIn)
    }

    func testProcessAuthCodeError() async throws {
        // Given
        let mockCode = "mockCode"
        authClientMock.signInThrowableError = TestError.test
        var isLoadingSequence: [Bool] = []
        sut.$isLoading
            .sink { isLoadingSequence.append($0) }
            .store(in: &cancellables)

        // When
        await sut.processAuthCode(mockCode)

        // Then
        XCTAssertEqual(isLoadingSequence, [false, true, false])
        XCTAssertEqual(sut.error as! DropBoxOauthViewModelTests.TestError, TestError.test)
        XCTAssertEqual(receivedNavEvent, nil)
    }
}
