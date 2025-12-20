import UIKit
import SnapKit

class GameTopBar: UIView {
    
    // Подложки
    private let coinBg = UIImageView(image: UIImage(named: "score_bg"))
    private let energyBg = UIImageView(image: UIImage(named: "score_bg"))
    
    // Иконки
    private let coinIcon = UIImageView(image: UIImage(named: "coin_icon"))
    private let energyIcon = UIImageView(image: UIImage(named: "clover_icon"))
    
    // Лейблы
    let coinLabel = UILabel()
    let energyLabel = UILabel()
    
    // Кнопка паузы
    private let pauseBtn = UIButton()
    
    var onPauseTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [coinLabel, energyLabel].forEach {
            $0.textColor = .white.withAlphaComponent(0.7)
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textAlignment = .center
        }
        
        coinLabel.text = "1500"
        energyLabel.text = "4"
        
        pauseBtn.setBackgroundImage(UIImage(named: "pause_btn"), for: .normal)
        pauseBtn.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        
        addSubview(coinBg)
        addSubview(energyBg)
        addSubview(coinIcon)
        addSubview(energyIcon)
        addSubview(pauseBtn)
        
        coinBg.addSubview(coinLabel)
        energyBg.addSubview(energyLabel)
        
        // --- ВЕРСТКА ---
        
        pauseBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        coinIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
        
        coinBg.snp.makeConstraints { make in
            make.leading.equalTo(coinIcon.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(35)
        }
        
        coinLabel.snp.makeConstraints { make in
            make.leading.equalTo(coinIcon.snp.trailing).offset(-5)
            make.trailing.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
        
        energyBg.snp.makeConstraints { make in
            make.leading.equalTo(coinBg.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(35)
        }
        
        energyLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        
        energyIcon.snp.makeConstraints { make in
            make.leading.equalTo(energyBg.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(35)
        }
    }
    
    @objc private func handlePause() {
        onPauseTapped?()
    }
}
