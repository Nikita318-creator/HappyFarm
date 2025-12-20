import UIKit
import SnapKit

class SplashViewController: UIViewController {
    
    var onComplete: (() -> Void)? 
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "flame.fill")
        iv.tintColor = .systemRed
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }
        
        // Запускаем таймер здесь один раз
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.onComplete?()
        }
    }
}
