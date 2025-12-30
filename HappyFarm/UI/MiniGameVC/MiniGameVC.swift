import UIKit
import SnapKit

class MiniGameVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let closeButton = UIButton(type: .system)
    private let gridContainer = UIView()
    private let rulesLabel = UILabel()
    
    // Твои ассеты из PlantType + 2 системных для ровного счета (20 карт)
    private let plantIcons: [String] = [
        "plant_carrot", "plant_onion", "plant_corn", "plant_pineapple",
        "plant_cabbage", "clover_standard", "clover_dark", "clover_gold",
        "leaf.fill", "cloud.rain.fill"
    ]
    
    private var cards: [String] = []
    private var cardButtons: [UIButton] = []
    
    private var firstFlippedIndex: Int?
    private var canFlip = true
    private var matchesFound = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        prepareGame()
    }
    
    private func prepareGame() {
        // 10 пар = 20 карточек (5 рядов по 4 колонки)
        cards = (plantIcons + plantIcons).shuffled()
        
        let rows = 5
        let cols = 4
        let spacing: CGFloat = 10
        
        cardButtons.forEach { $0.removeFromSuperview() }
        cardButtons.removeAll()
        
        // Создаем невидимые "ячейки-контейнеры" для выравнивания
        var previousRowAnchor = gridContainer.snp.top
        
        for row in 0..<rows {
            let rowStack = UIView()
            gridContainer.addSubview(rowStack)
            
            rowStack.snp.makeConstraints { make in
                make.top.equalTo(previousRowAnchor).offset(row == 0 ? 0 : spacing)
                make.left.right.equalToSuperview()
                make.height.equalToSuperview().dividedBy(rows).offset(-spacing)
            }
            
            var previousColAnchor = rowStack.snp.left
            
            for col in 0..<cols {
                let index = row * cols + col
                let button = UIButton()
                button.backgroundColor = .systemBrown
                button.layer.cornerRadius = 12
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
                button.tag = index
                button.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
                button.imageView?.contentMode = .scaleAspectFit
                
                rowStack.addSubview(button)
                cardButtons.append(button)
                
                button.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.left.equalTo(previousColAnchor).offset(col == 0 ? 0 : spacing)
                    make.width.equalToSuperview().dividedBy(cols).offset(-spacing)
                }
                
                previousColAnchor = button.snp.right
            }
            previousRowAnchor = rowStack.snp.bottom
        }
    }

    // В setupUI обязательно исправь привязки контейнера, чтобы он не тянулся до пола
    private func setupUI() {
        backgroundView.image = UIImage(named: "backgraundImg")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.addSubview(blur)
        blur.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        rulesLabel.text = "FARMER'S MEMORY TEST\nFind all matching pairs!"
        rulesLabel.textColor = .white
        rulesLabel.font = .systemFont(ofSize: 22, weight: .black)
        rulesLabel.numberOfLines = 0
        rulesLabel.textAlignment = .center
        view.addSubview(rulesLabel)
        rulesLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(dismissMiniGame), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().inset(20)
            make.size.equalTo(44)
        }
        
        view.addSubview(gridContainer)
        gridContainer.snp.makeConstraints { make in
            make.top.equalTo(rulesLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            // Фиксируем высоту относительно ширины, чтобы карточки были квадратными
            make.height.equalTo(gridContainer.snp.width).multipliedBy(1.25)
        }
    }
    
    @objc private func cardTapped(_ sender: UIButton) {
        let index = sender.tag
        guard canFlip, sender.backgroundColor == .systemBrown else { return }
        
        let iconName = cards[index]
        let isSystem = iconName.contains(".") // Проверка на системную иконку
        let img = isSystem ? UIImage(systemName: iconName) : UIImage(named: iconName)
        
        sender.setImage(img, for: .normal)
        sender.backgroundColor = .systemOrange
        sender.tintColor = .white
        
        if let first = firstFlippedIndex {
            if first == index { return }
            canFlip = false
            
            if cards[first] == cards[index] {
                // Совпало
                matchesFound += 1
                firstFlippedIndex = nil
                canFlip = true
                if matchesFound == plantIcons.count { showWin() }
            } else {
                // Не совпало
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.cardButtons[first].setImage(nil, for: .normal)
                    self.cardButtons[first].backgroundColor = .systemBrown
                    sender.setImage(nil, for: .normal)
                    sender.backgroundColor = .systemBrown
                    self.firstFlippedIndex = nil
                    self.canFlip = true
                }
            }
        } else {
            firstFlippedIndex = index
        }
    }
    
    private func showWin() {
        let alert = UIAlertController(title: "Skill Up!", message: "You matched all seeds!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.dismiss(animated: true) })
        present(alert, animated: true)
    }
    
    @objc private func dismissMiniGame() {
        dismiss(animated: true)
    }
}
