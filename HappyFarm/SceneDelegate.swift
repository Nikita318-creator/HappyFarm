import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let splashVC = SplashViewController()
        
        splashVC.onComplete = { [weak self] in
            self?.setRootViewController(ViewController(), animated: true)
        }
        
        window.rootViewController = splashVC
        self.window = window
        window.makeKeyAndVisible()
    }
    
    private func setRootViewController(_ vc: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = vc
        
        if animated {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
