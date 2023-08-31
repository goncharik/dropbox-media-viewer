import Dependencies
import SnapshotTesting
import SwiftUI
import XCTest

@testable import MediaViewer

@MainActor
final class SignInViewSnapshotTests: XCTestCase {
    func testSignInView() {
        let authClientMock = AuthClientMock()
        let view = withDependencies {
            $0.authClient = authClientMock
        } operation: {
            SignInView(viewModel: SignInViewModel(navHandler: { _ in }))
        }

        let hostingController = UIHostingController(rootView: view)
        /* By default the hosting controller doesn’t adjust its size based on the content of the view.
         See: https://www.pointfree.co/episodes/ep86-swiftui-snapshot-testing */
        hostingController.view.frame = UIScreen.main.bounds
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.navigationBar.prefersLargeTitles = true

        // Test default snapshot

        assertSnapshot(matching: navigationController, as: .image)
        assertSnapshot(matching: navigationController, as: .recursiveDescription)

        // Test config error alert

        authClientMock.checkAppConfigurationClosure = {
            throw ApiError.invalidAppConfig
        }

        view.viewModel.signInButtonTapped()
        assertSnapshot(matching: navigationController, as: .windowedImage)
        assertSnapshot(matching: navigationController, as: .recursiveDescription)
    }
}

extension Snapshotting where Value: UIViewController, Format == UIImage {
    static var windowedImage: Snapshotting {
        return Snapshotting<UIImage, UIImage>.image.asyncPullback { vc in
            Async<UIImage> { callback in
                UIView.setAnimationsEnabled(false)
                let window = UIApplication.shared.windows.first!
                window.rootViewController = vc
                DispatchQueue.main.async {
                    let image = UIGraphicsImageRenderer(bounds: window.bounds).image { ctx in
                        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                    }
                    callback(image)
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
    }
}
