import UIKit
import SnapKit

class GameVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let topBar = GameTopBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        topBar.onPauseTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 1. Фон
        backgroundView.image = UIImage(named: "backgraundImg")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 2. Верхняя панель
        view.addSubview(topBar)
        topBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
    }
}
