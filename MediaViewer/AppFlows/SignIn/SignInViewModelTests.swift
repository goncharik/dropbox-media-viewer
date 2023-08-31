import Dependencies
import XCTest

@testable import MediaViewer

@MainActor
final class SignInViewModelTests: XCTestCase {
    var sut: SignInViewModel!
    var authClientMock: AuthClientMock!
    var receivedNavEvent: SignInViewModel.NavigationEvents!

    override func setUpWithError() throws {
        try super.setUpWithError()
        authClientMock = AuthClientMock()
        sut = withDependencies({
            $0.authClient = authClientMock
        }, operation: {
            SignInViewModel(navHandler: { self.receivedNavEvent = $0 })
        })
    }

    override func tearDownWithError() throws {
        sut = nil
        authClientMock = nil
        receivedNavEvent = nil
        try super.tearDownWithError()
    }

    func testSignInSuccess() async throws {
        // Given
        authClientMock.checkAppConfigurationClosure = {}
        // When
        sut.signInButtonTapped()
        // Then
        XCTAssertNil(sut.error)
        XCTAssertEqual(receivedNavEvent, .dropboxOauth)
    }

    func testSignInConfigError() async throws {
        // Given
        authClientMock.checkAppConfigurationClosure = {
            throw ApiError.invalidAppConfig
        }
        // When
        sut.signInButtonTapped()
        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertNil(receivedNavEvent)
    }
}
