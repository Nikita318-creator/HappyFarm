import UIKit
import SnapKit

class GameVC: UIViewController {
    private let backgroundView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 1. Фон (Добавляем первым!)
        backgroundView.image = UIImage(named: "backgraundImg")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        
    }
}
