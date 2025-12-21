import UIKit
import SnapKit

class RulesVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let blackOverlay = UIView()
    private let titleImageView = UIImageView()
    private let backBtn = UIButton()
    
    // Зеленая подложка под текст
    private let greenBgView = UIImageView()
    private let rulesTextLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // 1. Общий фон
        backgroundView.image = UIImage(named: "backgraundImg")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        blackOverlay.backgroundColor = .black.withAlphaComponent(0.7)
        view.addSubview(blackOverlay)
        blackOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 2. Тайтл
        titleImageView.image = UIImage(named: "HOW_TO_PLAY_title")
        titleImageView.contentMode = .scaleAspectFit
        view.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(280)
        }
        
        // 3. Зеленая подложка (green background)
        greenBgView.image = UIImage(named: "green_background")
        greenBgView.contentMode = .scaleToFill
        view.addSubview(greenBgView)
        
        greenBgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(view.snp.width).multipliedBy(1.2)
        }
        
        // 4. Текст правил
        rulesTextLabel.text = """
        Grow & Harvest crops
        to get coins and 
        legendary clovers!

        Unlock more space!
        Every clover makes 
        your farm bigger!

        Get the best gear!
        Visit the shop to 
        speed up your harvest!
        """
        rulesTextLabel.textColor = .white
        rulesTextLabel.numberOfLines = 0
        rulesTextLabel.textAlignment = .center
        rulesTextLabel.font = .systemFont(ofSize: 24, weight: .black)
        
        greenBgView.addSubview(rulesTextLabel)
        rulesTextLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(30)
        }
        
        backBtn.setBackgroundImage(UIImage(named: "close_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        view.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.size.equalTo(105)
        }
    }
    
    @objc private func handleBack() {
        self.dismiss(animated: true)
    }
}
