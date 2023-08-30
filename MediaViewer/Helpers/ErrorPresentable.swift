import UIKit

public protocol ErrorPresentable {
    func showError(_ error: Error?)
}

public extension ErrorPresentable where Self: UIViewController {
    func showError(_ error: Error?) {
        guard let error = error else { return }
        var message = error.localizedDescription
        if let error = error as? ApiError {
            message = error.errorDescription
        }
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
