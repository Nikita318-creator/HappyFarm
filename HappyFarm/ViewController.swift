import UIKit
import SnapKit

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let homeVC = HomeVC()
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true)
        }
    }
}
