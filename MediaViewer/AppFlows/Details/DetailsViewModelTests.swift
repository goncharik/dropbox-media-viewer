import Combine
import Dependencies
@testable import MediaViewer
import XCTest

@MainActor
final class DetailsViewModelTests: XCTestCase {
    var sut: DetailsViewModel!
    var contentClientMock: ContentClientMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        contentClientMock = ContentClientMock()
        sut = withDependencies({
            $0.contentClient = contentClientMock
        }, operation: {
            DetailsViewModel(file: .stubImage)
        })
    }

    override func tearDownWithError() throws {
        sut = nil
        contentClientMock = nil
        try super.tearDownWithError()
    }

    func testContentImageProviderReturnsImage() async {
        // Given
        let image = UIImage()
        contentClientMock.fullsizeImageForReturnValue = image

        // When
        let result = await sut.contentImageProvider()()

        // Then
        XCTAssertEqual(result, image)
    }

    func testContentImageProviderThrows() async {
        // Given
        enum TestError: Error { case test }
        contentClientMock.fullsizeImageForThrowableError = TestError.test

        // When
        let expectation = XCTestExpectation(description: "contentImageProvider")
        let result = await sut.contentImageProvider()()

        // Then
        XCTAssertEqual(sut.error as? TestError, TestError.test)
    }

    func testContentVideoProviderReturnURL() async {
        // Given
        let videoURL = URL(string: "file:///path/video.mp4")!
        contentClientMock.videoFileUrlForReturnValue = videoURL

        // When
        let result = await sut.contentVideoProvider()()

        // Then
        XCTAssertEqual(result, videoURL)
    }

    func testContentVideoProviderThrows() async {
        // Given
        enum TestError: Error { case test }
        contentClientMock.videoFileUrlForThrowableError = TestError.test

        // When
        let result = await sut.contentVideoProvider()()

        // Then
        XCTAssertEqual(sut.error as? TestError, TestError.test)
    }
}
