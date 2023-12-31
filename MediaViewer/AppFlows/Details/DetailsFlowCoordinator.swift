import UIKit
import SwiftUI
import Dependencies

@MainActor
final class DetailsFlowCoordinator {
    private let navigation: UINavigationController
    
    init(with navigation: UINavigationController) {
        self.navigation = navigation        
    }

    /// Entry point to the flow
    func start(_ file: FileEntry) {
        let viewModel = DetailsViewModel(
            file: file
        )
        let view = UIHostingController(
            rootView: DetailsView(viewModel: viewModel)
        )

        navigation.pushViewController(view, animated: true)
    }
}
