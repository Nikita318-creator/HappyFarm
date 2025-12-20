import UIKit
import SnapKit

class GameTopBar: UIView {
    
    enum Keys {
        static let coins = "user_coins_count"
        static let energy = "user_energy_count"
    }
    
    private let coinBg = UIImageView(image: UIImage(named: "score_bg"))
    private let energyBg = UIImageView(image: UIImage(named: "score_bg"))
    private let coinIcon = UIImageView(image: UIImage(named: "coin_icon"))
    private let energyIcon = UIImageView(image: UIImage(named: "clover_icon"))
    private let coinLabel = UILabel()
    private let energyLabel = UILabel()
    private let pauseBtn = UIButton()
    
    // Загружаем начальные значения сразу из памяти
    private(set) var coins: Int = UserDefaults.standard.integer(forKey: Keys.coins)
    private(set) var energy: Int = UserDefaults.standard.integer(forKey: Keys.energy)

    var onPauseTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Метод для обновления и сохранения
    func updateScore(newCoinsCount: Int, newEnergyCount: Int) {
        coins += newCoinsCount
        energy += newEnergyCount
        
        // Сохраняем в UserDefaults
        UserDefaults.standard.set(coins, forKey: Keys.coins)
        UserDefaults.standard.set(energy, forKey: Keys.energy)
        
        // Обновляем текст
        coinLabel.text = "\(coins)"
        energyLabel.text = "\(energy)"
    }
    
    private func setupViews() {
        [coinLabel, energyLabel].forEach {
            $0.textColor = .white.withAlphaComponent(0.9)
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textAlignment = .center
        }
        
        // Устанавливаем текущие значения в лейблы
        coinLabel.text = "\(coins)"
        energyLabel.text = "\(energy)"
        
        pauseBtn.setBackgroundImage(UIImage(named: "pause_btn"), for: .normal)
        pauseBtn.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        
        // Добавляем элементы на главный вью
        [coinBg, energyBg, coinIcon, energyIcon, pauseBtn].forEach { addSubview($0) }
        
        // Лейблы кладем внутрь подложек
        coinBg.addSubview(coinLabel)
        energyBg.addSubview(energyLabel)
        
        // --- ВЕРСТКА ---
        
        pauseBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        coinIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
        
        coinBg.snp.makeConstraints { make in
            make.leading.equalTo(coinIcon.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(35)
        }
        
        // Центрируем лейбл внутри его бэкграунда
        coinLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        }
        
        energyBg.snp.makeConstraints { make in
            make.leading.equalTo(coinBg.snp.trailing).offset(15) // Чуть увеличил отступ между группами
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(35)
        }
        
        energyLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        energyIcon.snp.makeConstraints { make in
            make.leading.equalTo(energyBg.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(35)
        }
    }
    
    @objc private func handlePause() {
        onPauseTapped?()
    }
}
