import UIKit
import SwiftUI
import Dependencies

@MainActor
public final class HomeFlowCoordinator {
    private let navigation: UINavigationController
    
    public init(with navigation: UINavigationController) {
        self.navigation = navigation        
    }

    /// Entry point to the flow
    public func start() {
        let viewModel = HomeViewModel(
            dependencies: .init(),
            navHandler: navigate
        )
        let view = UIHostingController(
            rootView: HomeView(viewModel: viewModel)
        )

        navigation.setViewControllers([view], animated: true)    
    }

    // MARK: - Private helpers

    private func navigate(_ event: HomeViewModel.NavigationEvents) {
        switch event {
        case .logout:
            StartFlowCoordinator(with: navigation).start()
        }
    }
}
