import UIKit
import SnapKit

class LevelsVC: UIViewController {
    
    private let backgroundImage = UIImageView()
    private var collectionView: UICollectionView!
    
    private let totalLevels = 150
    private var unlockedLevel: Int {
        // Берем сохраненный уровень, по дефолту 1
        let saved = UserDefaults.standard.integer(forKey: "unlocked_level")
        return saved == 0 ? 1 : saved
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    // Обновляем сетку при возврате из игры (чтобы новые уровни открылись)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setupUI() {
        backgroundImage.image = UIImage(named: "backgraundImg")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "SELECT LEVEL"
        titleLabel.font = .systemFont(ofSize: 32, weight: .black)
        titleLabel.textColor = .white
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = 3.0
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = .black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20

        closeButton.addTarget(self, action: #selector(exitGame), for: .touchUpInside)

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().inset(20)
            make.size.equalTo(40)
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 40, right: 30)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(LevelCell.self, forCellWithReuseIdentifier: "LevelCell")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension LevelsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalLevels
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCell
        let levelNum = indexPath.row + 1
        let isLocked = levelNum > unlockedLevel
        cell.configure(number: levelNum, isLocked: isLocked)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let levelNum = indexPath.row + 1
        
        guard levelNum <= unlockedLevel else {
            if let cell = collectionView.cellForItem(at: indexPath) as? LevelCell { cell.shake() }
            return
        }
        
        let story = getStoryForLevel(levelNum)
        
        // Функция запуска игры
        let startGame = { [weak self] in
            let gameVC = GameVC()
            gameVC.currentLevel = indexPath.row
            gameVC.modalPresentationStyle = .fullScreen
            self?.present(gameVC, animated: true)
        }
        
        if levelNum <= 10 && !story.isEmpty {
            let storyVC = StoryVC()
            storyVC.slides = story
            storyVC.modalPresentationStyle = .fullScreen
            
            // Хендлер сработает ВНУТРИ completion блока dismiss-а в StoryVC
            storyVC.onStoryFinished = {
                startGame()
            }
            
            self.present(storyVC, animated: true)
        } else {
            startGame()
        }
    }
    
    @objc private func exitGame() {
        self.dismiss(animated: true)
    }
}

// MARK: - Level Cell
class LevelCell: UICollectionViewCell {
    private let bgView = UIView()
    private let label = UILabel()
    private let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupCell() {
        bgView.layer.cornerRadius = 20
        bgView.layer.borderWidth = 3
        bgView.layer.borderColor = UIColor.white.cgColor
        
        // Тень для красоты
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 4)
        bgView.layer.shadowRadius = 4
        bgView.layer.shadowOpacity = 0.3
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        label.font = .systemFont(ofSize: 26, weight: .black)
        label.textColor = .white
        bgView.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        
        lockIcon.tintColor = .white.withAlphaComponent(0.9)
        bgView.addSubview(lockIcon)
        lockIcon.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8)
            make.size.equalTo(18)
        }
    }
    
    func configure(number: Int, isLocked: Bool) {
        label.text = "\(number)"
        
        if isLocked {
            bgView.backgroundColor = .gray.withAlphaComponent(0.8)
            label.alpha = 0.3 // Делаем цифру тусклой под замком
            lockIcon.isHidden = false
            bgView.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            bgView.backgroundColor = .systemOrange
            label.alpha = 1.0
            lockIcon.isHidden = true
            bgView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.duration = 0.3
        animation.values = [-5, 5, -5, 5, 0]
        layer.add(animation, forKey: "shake")
    }
}

extension LevelsVC {
    func getStoryForLevel(_ level: Int) -> [StorySlide] {
        switch level {
        case 1:
            return [
                StorySlide(text: "Hello there! I'm Barnaby. Welcome to our family farm!", imageName: "farmer_happy"),
                StorySlide(text: "But look at this dust... The Great Drought has taken everything.", imageName: "farmer_sad"),
                StorySlide(text: "Legend says only a Magical Clover can summon the rain spirits.", imageName: "farmer_thinking"),
                StorySlide(text: "The soil is dry, but if we plant now, we might have a chance.", imageName: "farmer_talk"),
                StorySlide(text: "Try to grow your first clover. Our future depends on it!", imageName: "farmer_happy2")
            ]
        case 2:
            return [
                StorySlide(text: "You did it! I saw a tiny green sprout this morning.", imageName: "farmer_happy"),
                StorySlide(text: "But the sun is getting hotter. The ground is turning into stone.", imageName: "farmer_sad"),
                StorySlide(text: "We need more than just luck; we need dedication.", imageName: "farmer_thinking"),
                StorySlide(text: "It will take longer for the seeds to wake up in this heat.", imageName: "farmer_talk"),
                StorySlide(text: "Don't lose hope! Let's plant another batch.", imageName: "farmer_happy")
            ]
        case 3:
            return [
                StorySlide(text: "Barnaby here. Bad news... The water in the well is almost gone.", imageName: "farmer_sad"),
                StorySlide(text: "The plants are struggling. They need constant care now.", imageName: "farmer_thinking"),
                StorySlide(text: "Did you hear that? The crows are gathering in the old oak tree.", imageName: "farmer_angry"),
                StorySlide(text: "They want our seeds! We must harvest quickly before they arrive.", imageName: "farmer_talk"),
                StorySlide(text: "Concentrate! We need that clover to survive the week.", imageName: "farmer_thinking")
            ]
        case 4:
            return [
                StorySlide(text: "The heatwave is relentless... Even the shadows feel hot.", imageName: "farmer_sad"),
                StorySlide(text: "I found an old book in the cellar. It speaks of the 'Iron Soil'.", imageName: "farmer_thinking"),
                StorySlide(text: "It says the more we plant, the harder the earth fights back.", imageName: "farmer_talk"),
                StorySlide(text: "Expect the growth to be even slower today. The earth is thirsty.", imageName: "farmer_sad"),
                StorySlide(text: "Keep going! I'll go check the southern fields for any signs of rain.", imageName: "farmer_happy")
            ]
        case 5:
            return [
                StorySlide(text: "I'm back! No rain yet, but the wind is changing direction.", imageName: "farmer_happy"),
                StorySlide(text: "Look at your garden! It's the only green spot left in the valley.", imageName: "farmer_talk"),
                StorySlide(text: "But beware—the spirits of the drought are angry.", imageName: "farmer_angry"),
                StorySlide(text: "The time it takes to grow a clover is nearly doubling now.", imageName: "farmer_thinking"),
                StorySlide(text: "You are our last hope, gardener. Show them your spirit!", imageName: "farmer_happy")
            ]
        case 6:
            return [
                StorySlide(text: "Listen... can you hear that low rumble in the distance?", imageName: "farmer_happy"),
                StorySlide(text: "Is it thunder? Or just my hungry stomach? Haha!", imageName: "farmer_happy"),
                StorySlide(text: "Actually, it's serious. The soil has become incredibly dense.", imageName: "farmer_thinking"),
                StorySlide(text: "You'll need to wait much longer for the harvest on this level.", imageName: "farmer_talk"),
                StorySlide(text: "Stay sharp. The final ritual is approaching!", imageName: "farmer_happy")
            ]
        case 7:
            return [
                StorySlide(text: "The sky is turning gray, but not with rain clouds... It's dust.", imageName: "farmer_sad"),
                StorySlide(text: "A dust storm is coming. We must secure the patches!", imageName: "farmer_angry"),
                StorySlide(text: "I've never seen the plants struggle this much.", imageName: "farmer_sad"),
                StorySlide(text: "It feels like the time itself is slowing down in this garden.", imageName: "farmer_thinking"),
                StorySlide(text: "Don't let the dust bury our dreams! To work!", imageName: "farmer_talk")
            ]
        case 8:
            return [
                StorySlide(text: "You're still here? Your persistence is legendary, my friend.", imageName: "farmer_happy"),
                StorySlide(text: "We've collected enough basic clovers, but the ritual needs more.", imageName: "farmer_thinking"),
                StorySlide(text: "The soil is so hard now, it's like planting in solid rock.", imageName: "farmer_talk"),
                StorySlide(text: "Wait for the right moment. Patience is your best tool today.", imageName: "farmer_thinking"),
                StorySlide(text: "We are so close! I can almost feel the first drop of water.", imageName: "farmer_happy")
            ]
        case 9:
            return [
                StorySlide(text: "The crows have left. They know something is about to happen.", imageName: "farmer_thinking"),
                StorySlide(text: "The air is heavy. The magic is concentrating in this very spot.", imageName: "farmer_talk"),
                StorySlide(text: "One more harvest of the Rare Clover and the spirits will wake.", imageName: "farmer_happy"),
                StorySlide(text: "It will be the longest wait of your life, but it's worth it.", imageName: "farmer_sad"),
                StorySlide(text: "Prepare yourself. The final stage is almost here!", imageName: "farmer_happy")
            ]
        case 10:
            return [
                StorySlide(text: "This is it! Level 10. The peak of our journey.", imageName: "farmer_happy"),
                StorySlide(text: "The legendary Gold Clover must be grown today.", imageName: "farmer_thinking"),
                StorySlide(text: "The earth is resisting with all its might. It will be slow.", imageName: "farmer_talk"),
                StorySlide(text: "If you succeed, the Great Drought will end forever.", imageName: "farmer_happy"),
                StorySlide(text: "Good luck, Gardener. All of us are praying for your success!", imageName: "farmer_happy")
            ]
        default:
            return []
        }
    }
}
