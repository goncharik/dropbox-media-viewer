import Combine
import Foundation
import IdentifiedCollections

struct Item: Identifiable {
    var id: UUID
}

@MainActor
final class HomeViewModel: ObservableObject  {
    enum NavigationEvents {
        case logout
    }

    struct Dependencies {
        // ADD DEPENDENCIES HERE    
    }

    private let dependencies: Dependencies
    private let navHandler: @MainActor (NavigationEvents) -> Void

    @Published private(set) var isLoading = false
    @Published private(set) var items: IdentifiedArrayOf<Item> = []
    
    @Published var error: Error?    

    init(
        dependencies: Dependencies, 
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.dependencies = dependencies
        self.navHandler = navHandler
    }

    func load() async {
        isLoading = true
        error = nil
        
        do {
            // ADD API CALL HERE
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func itemSelected(_ item: Item) {
        
    }

    func logout() async {
        await AuthSession(appEnv: .live()).logout()
        navHandler(.logout)
    }
}
