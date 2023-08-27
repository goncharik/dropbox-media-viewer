import UIKit

@MainActor
public final class StartFlowCoordinator {
    private let navigation: UINavigationController

//    @Dependency(\.authClient) private var authClient
    
    public init(with navigation: UINavigationController) {
        self.navigation = navigation
    }

    /// Entry point to the flow
    public func start() {
        let view = UIViewController()
        view.title = "test"
        view.view.backgroundColor = .white
        navigation.setViewControllers([view], animated: true)
//        if authClient.isAuthorized() {
//            HomeFlowCoordinator(with: navigation).start()
//        } else {
//            SignInFlowCoordinator(with: navigation).start()
//        }
    }
}
