import UIKit
import SnapKit

class GameVC: UIViewController {
    
    // Удаляем shared, чтобы каждый уровень инициализировался чисто
    private let backgroundView = UIImageView()
    private let topBar = GameTopBar()
    
    // Базовые тайминги для ячеек (сек)
    private let baseGrowthTimes: [Int] = [5, 10, 15, 20, 25, 30, 40, 50, 60]
    private var collectionView: UICollectionView!
    
    private let tutorialLabel = UILabel()
    private let tapPointer = UIImageView(image: UIImage(named: "tap"))
    private let tutorialKey = "did_finish_tutorial"
    
    private let miniGameButton = UIButton(type: .custom)
    private let skillHintBubble = UIView()
    private let skillHintLabel = UILabel()
    private let miniGameKey = "did_show_mini_game_hint"
    
    // Индекс уровня, который прилетает из LevelsVC
    var currentLevel: Int = 0
    private var isLevelCompleted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        showMiniGameHintIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTutorial()
    }
    
    private func checkTutorial() {
        if !UserDefaults.standard.bool(forKey: tutorialKey) {
            setupTutorialUI()
        }
    }
    
    private func setupTutorialUI() {
        tutorialLabel.text = "Tap on the patch to plant a crop"
        tutorialLabel.backgroundColor = .black.withAlphaComponent(0.8)
        tutorialLabel.textColor = .white
        tutorialLabel.textAlignment = .center
        tutorialLabel.font = .systemFont(ofSize: 16, weight: .black)
        tutorialLabel.layer.cornerRadius = 12
        tutorialLabel.clipsToBounds = true
        tutorialLabel.numberOfLines = 0
        
        view.addSubview(tutorialLabel)
        view.addSubview(tapPointer)
        
        tutorialLabel.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(40)
            make.height.greaterThanOrEqualTo(50)
        }
        
        collectionView.layoutIfNeeded()
        if let firstCell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) {
            tapPointer.snp.makeConstraints { make in
                make.center.equalTo(firstCell.snp.center).offset(20)
                make.size.equalTo(50)
            }
            
            UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .repeat], animations: {
                self.tapPointer.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        }
    }
    
    private func finishTutorial() {
        UserDefaults.standard.set(true, forKey: tutorialKey)
        tutorialLabel.removeFromSuperview()
        tapPointer.removeFromSuperview()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        backgroundView.image = UIImage(named: "farm_image")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        view.addSubview(topBar)
        
        topBar.onPauseTapped = { [weak self] in
            self?.showPauseMenu()
        }
        
        topBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
        
        setupMiniGameButton()
    }
    
    private func setupMiniGameButton() {
        miniGameButton.setImage(UIImage(named: "skills_icon"), for: .normal) // Создай иконку в ассетах
        miniGameButton.backgroundColor = .systemOrange
        miniGameButton.layer.cornerRadius = 25
        miniGameButton.layer.borderWidth = 3
        miniGameButton.layer.borderColor = UIColor.white.cgColor
        miniGameButton.addTarget(self, action: #selector(openMiniGame), for: .touchUpInside)
        
        view.addSubview(miniGameButton)
        miniGameButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }
        
        // Кастомный поп-ап (баббл)
        skillHintBubble.backgroundColor = .systemBlue
        skillHintBubble.layer.cornerRadius = 15
        skillHintBubble.alpha = 0
        
        skillHintLabel.text = "Bored waiting? Check your skills here!"
        skillHintLabel.textColor = .white
        skillHintLabel.font = .systemFont(ofSize: 14, weight: .bold)
        skillHintLabel.numberOfLines = 0
        skillHintLabel.textAlignment = .center
        
        view.addSubview(skillHintBubble)
        skillHintBubble.addSubview(skillHintLabel)
        
        skillHintBubble.snp.makeConstraints { make in
            make.bottom.equalTo(miniGameButton.snp.top).offset(-15)
            make.right.equalTo(miniGameButton)
            make.width.equalTo(180)
        }
        
        skillHintLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(10) }
    }

    // Вызывай это в viewDidAppear после туториала
    private func showMiniGameHintIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: miniGameKey) else { return }
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut) {
            self.skillHintBubble.alpha = 1
            self.skillHintBubble.transform = CGAffineTransform(translationX: 0, y: -10)
        } completion: { _ in
            // Скрываем через 5 секунд
            UIView.animate(withDuration: 0.5, delay: 5.0, options: .curveEaseIn) {
                self.skillHintBubble.alpha = 0
            } completion: { _ in
                UserDefaults.standard.set(true, forKey: self.miniGameKey)
            }
        }
    }

    @objc private func openMiniGame() {
        skillHintBubble.isHidden = true
        let miniVC = MiniGameVC()
        miniVC.modalPresentationStyle = .fullScreen
        self.present(miniVC, animated: true)
    }
    
    private func showPauseMenu() {
        let pauseView = PauseView()
        view.addSubview(pauseView)
        pauseView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        pauseView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            pauseView.alpha = 1
        }
        
        pauseView.onMenuTapped = { [weak self] in
            self?.dismiss(animated: true)
            pauseView.alpha = 0
            pauseView.removeFromSuperview()
        }
        
        pauseView.onCloseTapped = {
            UIView.animate(withDuration: 0.3, animations: {
                pauseView.alpha = 0
            }) { _ in
                pauseView.removeFromSuperview()
            }
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        let availableWidth = view.frame.width - 110
        let side = (availableWidth - (spacing * 2)) / 3
        
        layout.itemSize = CGSize(width: side, height: side)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GardenCell.self, forCellWithReuseIdentifier: GardenCell.reuseId)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(70)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(collectionView.snp.width)
        }
    }
    
    private func checkWinCondition(plant: PlantType) {
        if isLevelCompleted { return }
        
        // Условие победы: если собрали любой тип клевера
        let cloverTypes: [PlantType] = [.cloverBase, .cloverRare, .cloverGold]
        
        if cloverTypes.contains(plant) {
            isLevelCompleted = true
            
            // Сохраняем прогресс: если прошли текущий уровень, открываем следующий
            let nextLevelIndex = currentLevel + 1
            let currentlySaved = UserDefaults.standard.integer(forKey: "unlocked_level")
            if (nextLevelIndex + 1) > currentlySaved {
                UserDefaults.standard.set(nextLevelIndex + 1, forKey: "unlocked_level")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.showWinScreen()
            }
        }
    }
    
    private func showWinScreen() {
        let alert = UIAlertController(title: "Level \(currentLevel + 1) Done!", message: "You found the clover! Next level unlocked.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Awesome", style: .default) { _ in
            self.dismiss(animated: true)
        })
        self.present(alert, animated: true)
    }
    
    private func showFullPlantAnimation(plant: PlantType) {
        let fullImageName = plant.rawValue + "_full"
        let fullImageView = UIImageView(image: UIImage(named: fullImageName))
        fullImageView.contentMode = .scaleAspectFit
        fullImageView.alpha = 0
        
        view.addSubview(fullImageView)
        fullImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200)
        }
        
        fullImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .curveEaseOut) {
            fullImageView.alpha = 1
            fullImageView.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseIn) {
                fullImageView.alpha = 0
                fullImageView.transform = CGAffineTransform(translationX: 0, y: -100)
            } completion: { _ in
                fullImageView.removeFromSuperview()
                self.calculateRewards(for: plant)
                self.checkWinCondition(plant: plant)
            }
        }
    }
    
    private func calculateRewards(for plant: PlantType) {
        var coinsReward = 0
        var energyReward = 0
        
        switch plant {
        case .cloverBase, .cloverRare, .cloverGold:
            coinsReward = [100, 150, 200].randomElement() ?? 100
            energyReward = 1
        default:
            coinsReward = [10, 20, 30, 40, 50].randomElement() ?? 10
            energyReward = 0
        }
        
        topBar.updateScore(newCoinsCount: coinsReward, newEnergyCount: energyReward)
    }
    
    @objc private func exitGame() {
        self.dismiss(animated: true)
    }
}

extension GameVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GardenCell.reuseId, for: indexPath) as! GardenCell
        cell.configure(with: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GardenCell else { return }
        
        let isTutorialActive = !UserDefaults.standard.bool(forKey: tutorialKey)
        
        if cell.isReady {
            if let plant = cell.harvest() {
                showFullPlantAnimation(plant: plant)
                if isTutorialActive {
                    finishTutorial()
                }
            }
        } else {
            // Расчет сложности: Базовое время + (5% за каждый уровень)
            let baseTime = Double(baseGrowthTimes[indexPath.row])
            let levelDifficultyMultiplier = 1.0 + (Double(currentLevel) * 0.05)
            let finalTime = Int(baseTime * levelDifficultyMultiplier)
            
            cell.startTimer(seconds: finalTime)
            
            if isTutorialActive && indexPath.row == 0 {
                tutorialLabel.text = "Wait for it to grow and tap to harvest"
                tapPointer.isHidden = true
            }
        }
    }
}
