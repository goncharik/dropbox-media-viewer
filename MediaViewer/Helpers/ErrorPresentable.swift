import UIKit

public protocol ErrorPresentable {
    func showError(_ error: Error?)
}

public extension ErrorPresentable where Self: UIViewController {
    func showError(_ error: Error?) {
        guard let error = error else { return }
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
