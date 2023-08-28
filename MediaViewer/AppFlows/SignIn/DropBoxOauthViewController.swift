import Combine
import UIKit
import WebKit

final class DropBoxOauthViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    private let viewModel: DropBoxOauthViewModel

    private var webView: WKWebView!
    private var acitvityIndicator: UIActivityIndicatorView!

    init(with viewModel: DropBoxOauthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupBindings()
        startLoading()
    }

    private func setupUI() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        acitvityIndicator = UIActivityIndicatorView(style: .large)
        acitvityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(acitvityIndicator)
        NSLayoutConstraint.activate([
            acitvityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            acitvityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])    
    }

    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                $0 ? self?.acitvityIndicator.startAnimating() : self?.acitvityIndicator.stopAnimating()
                self?.webView.isHidden = $0
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.showError($0)
            }
            .store(in: &cancellables)
    }

    private func startLoading() {
        webView.load(URLRequest(url: viewModel.authUrl()))
    }
}

extension DropBoxOauthViewController: WKNavigationDelegate {
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check if the URL contains the redirect URI and extract the authorization code
        if let redirectURL = navigationAction.request.url,
           redirectURL.absoluteString.starts(with: viewModel.redirectUri()),
           let authorizationCode = extractAuthorizationCode(from: redirectURL)
        {
            Task {
                await viewModel.processAuthCode(authorizationCode)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func extractAuthorizationCode(from redirectURL: URL) -> String? {
        guard let components = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            return nil
        }

        for queryItem in queryItems {
            if queryItem.name == "code" {
                return queryItem.value
            }
        }

        return nil
    }
}

extension DropBoxOauthViewController: ErrorPresentable {}
