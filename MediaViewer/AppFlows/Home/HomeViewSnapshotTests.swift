import Dependencies
import SnapshotTesting
import SwiftUI
import XCTest

@testable import MediaViewer

@MainActor
class HomeViewSnapshotTests: XCTestCase {
    func testHomeView() async {
        let fileEntryRepoMock = FileEntryRepositoryMock()
        let authClientMock = AuthClientMock()
        let contentClientMock = ContentClientMock()

        let viewModel = withDependencies({
            $0.authClient = authClientMock
            $0.fileEntryRepo = fileEntryRepoMock
            $0.contentClient = contentClientMock
        }, operation: {
            HomeViewModel(navHandler: { _ in })
        })
        let view = HomeView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: view)
        /* By default the hosting controller doesn’t adjust its size based on the content of the view.
         See: https://www.pointfree.co/episodes/ep86-swiftui-snapshot-testing */
        hostingController.view.frame = UIScreen.main.bounds
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.navigationBar.prefersLargeTitles = true

        assertSnapshot(matching: navigationController, as: .image)
    }
}
