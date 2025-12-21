import UIKit
import SnapKit

class GameVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let topBar = GameTopBar()
//    private let growthTimes = [1, 2, 3, 6, 9, 12, 30, 30, 30] 
    private let growthTimes = [10, 20, 30, 60, 90, 120, 300, 300, 300]

    private var collectionView: UICollectionView!
    
    private let tutorialLabel = UILabel()
    private let tapPointer = UIImageView(image: UIImage(named: "tap"))
    private let tutorialKey = "did_finish_tutorial"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
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
            cell.startTimer(seconds: growthTimes[indexPath.row])
            
            if isTutorialActive && indexPath.row == 0 {
                tutorialLabel.text = "Wait for it to grow and tap to harvest"
                tapPointer.isHidden = true
            }
        }
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
}
