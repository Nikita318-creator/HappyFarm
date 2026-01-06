import UIKit
import WebKit
import SnapKit

class ViewController: UIViewController {
    
    private var splashVC: StartVC?
    private var dataCheckTimer: Timer?
    private var deadlineTimer: Timer?
    
    private var mainImageView: WKWebView?
    private var popupImageView: WKWebView?
    
    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let navigationContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
        view.backgroundColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if splashVC == nil {
            showSplashScreen()
            startDataCheckTimer()
            startDeadlineTimer()
        }
    }
    
    private func showMainInterface() {
        let homeVC = HomeVC()
        homeVC.modalPresentationStyle = .fullScreen
        self.present(homeVC, animated: true)
    }
    
    private func showSplashScreen() {
        let splash = StartVC()
        addChild(splash)
        splash.view.frame = view.bounds
        view.addSubview(splash.view)
        splash.didMove(toParent: self)
        self.splashVC = splash
    }
    
    private func dismissSplashScreen() {
        guard let splash = splashVC else { return }
        
        // Останавливаем ОБА таймера
        dataCheckTimer?.invalidate()
        dataCheckTimer = nil
        deadlineTimer?.invalidate()
        deadlineTimer = nil
        
        UIView.animate(withDuration: 0.3, animations: {
            splash.view.alpha = 0
        }, completion: { _ in
            splash.willMove(toParent: nil)
            splash.view.removeFromSuperview()
            splash.removeFromParent()
            self.splashVC = nil
            
            self.loadMainContent()
        })
    }
    
    private func startDataCheckTimer() {
        dataCheckTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkForData), userInfo: nil, repeats: true)
    }
    
    private func startDeadlineTimer() {
        deadlineTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            print("⏳ Deadline reached. Moving forward regardless of data.")
            self?.dismissSplashScreen()
        }
    }
    
    @objc private func checkForData() {
        let finalURL = BaseUseCase.shared.finalDataImageString
        
        if finalURL != nil {
            print("✅ Data received from Firebase.")
            dismissSplashScreen()
        }
    }
    
    private func loadMainContent() {
        let finalDataImageURLString = BaseUseCase.shared.finalDataImageString ?? ""
            
        if finalDataImageURLString.isEmpty {
            showMainInterface()
            return
        }
            
        guard let finalDataImageURL = URL(string: finalDataImageURLString) else { return }

        setupNavigationUI()

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
            
        let mainImageView = WKWebView(frame: .zero, configuration: config)
        mainImageView.backgroundColor = .black
        mainImageView.navigationDelegate = self
        mainImageView.uiDelegate = self
        mainImageView.allowsBackForwardNavigationGestures = true
            
        let customUserAgent = "Version/17.2 Mobile/15E148 Safari/604.1"
        mainImageView.customUserAgent = customUserAgent
            
        view.addSubview(mainImageView)
        
        mainImageView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        navigationContainer.backgroundColor = .black
        view.bringSubviewToFront(navigationContainer)
            
        let request = URLRequest(url: finalDataImageURL)
        mainImageView.load(request)
        self.mainImageView = mainImageView
    }
    
    private func setupNavigationUI() {
        view.addSubview(navigationContainer)
        navigationContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
            make.height.equalTo(34)
        }
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navigationContainer.addSubview(backButton)
        
        forwardButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        forwardButton.tintColor = .white
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        navigationContainer.addSubview(forwardButton)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(34)
        }
        
        forwardButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(34)
        }
        
        updateNavigationButtons()
    }

    
    private var activeImageView: WKWebView? {
        return popupImageView ?? mainImageView
    }

    @objc private func goBack() {
        guard let imageView = activeImageView else { return }
        
        if imageView.canGoBack {
            imageView.goBack()
        } else {
            if imageView == popupImageView {
                closePopup()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateNavigationButtons()
        }
    }

    @objc private func goForward() {
        guard let imageView = activeImageView else { return }
        
        if imageView.canGoForward {
            imageView.goForward()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateNavigationButtons()
        }
    }
    
    private func closePopup() {
        guard let popup = popupImageView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            popup.alpha = 0
        }) { _ in
            popup.removeFromSuperview()
            self.popupImageView = nil
            self.updateNavigationButtons()
        }
    }

    private func updateNavigationButtons() {
        backButton.isHidden = false
        forwardButton.isHidden = false
        
        guard let webView = activeImageView else {
            backButton.isEnabled = false
            forwardButton.isEnabled = false
            backButton.alpha = 0.3
            forwardButton.alpha = 0.3
            return
        }
        
        let isPopup = (webView == popupImageView)
        let canGoBack = webView.canGoBack
        let canGoForward = webView.canGoForward
        
        backButton.isEnabled = canGoBack || isPopup
        forwardButton.isEnabled = canGoForward
        
        backButton.alpha = backButton.isEnabled ? 1.0 : 0.3
        forwardButton.alpha = forwardButton.isEnabled ? 1.0 : 0.3
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let scheme = (url.scheme ?? "").lowercased()
        
        let internalSchemes: Set<String> = ["http", "https", "about", "srcdoc", "blob", "data", "javascript", "file"]
        
        if internalSchemes.contains(scheme) {
            
            if let host = url.host?.lowercased(),
               host.contains("apps.apple.com") || host.contains("itunes.apple.com") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            decisionHandler(.allow)
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationButtons()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        updateNavigationButtons()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateNavigationButtons()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateNavigationButtons()
    }
}

extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let popup = WKWebView(frame: .zero, configuration: configuration)
        popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popup.navigationDelegate = self
        popup.uiDelegate = self
        
        popup.allowsBackForwardNavigationGestures = true
        popup.customUserAgent = webView.customUserAgent
        
        view.addSubview(popup)
        
        popup.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        popup.alpha = 0
        UIView.animate(withDuration: 0.3) {
            popup.alpha = 1
        }
        
        self.popupImageView = popup
        
        view.bringSubviewToFront(navigationContainer)
        updateNavigationButtons()
        
        return popup
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler() }))
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler(true) }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completionHandler(false) }))
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = defaultText }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler(alert.textFields?.first?.text) }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completionHandler(nil) }))
        present(alert, animated: true)
    }
}
