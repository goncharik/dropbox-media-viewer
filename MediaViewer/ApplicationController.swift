import UIKit

@MainActor
final class ApplicationController {
    private let navigation: UINavigationController
    private var mainFlow: StartFlowCoordinator?

    init(navigation: UINavigationController) {
        self.navigation = navigation

        setupStartFlow()
    }

    func setupWithLaunchOptions(_: UIScene.ConnectionOptions?) {
        mainFlow?.start()
    }

    func didBecomeActive() {}
    func willResignActive() {}

    // MARK: - Private helpers

    private func setupStartFlow() {
        mainFlow = StartFlowCoordinator(with: navigation)

//        @Dependency(\.tokenStorage) var tokenStorage;
//
//        tokenStorage.didClearTokens = { [weak self] in
//            self?.mainFlow?.start()
//        }
    }
}
