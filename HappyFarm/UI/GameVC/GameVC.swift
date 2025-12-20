import UIKit
import SnapKit

class GameVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let topBar = GameTopBar()
//    private let growthTimes = [10, 20, 30, 60, 90, 120, 300, 300, 300]
    private let growthTimes = [1, 2, 3, 6, 9, 12, 30, 30, 30]

    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        backgroundView.image = UIImage(named: "farm_image")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        view.addSubview(topBar)
        topBar.onPauseTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        topBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let side = (view.frame.width - 60) / 3
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
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(view.snp.width)
        }
    }
}

// MARK: - CollectionView Extension
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
        
        if cell.isReady {
            if let plant = cell.harvest() {
                showFullPlantAnimation(plant: plant)
                calculateRewards(for: plant)
            }
        } else {
            cell.startTimer(seconds: growthTimes[indexPath.row])
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
        
        // Красивое появление
        fullImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .curveEaseOut) {
            fullImageView.alpha = 1
            fullImageView.transform = .identity
        } completion: { _ in
            // Исчезновение через 3 секунды
            UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseIn) {
                fullImageView.alpha = 0
                fullImageView.transform = CGAffineTransform(translationX: 0, y: -100)
            } completion: { _ in
                fullImageView.removeFromSuperview()
            }
        }
    }
    
    private func calculateRewards(for plant: PlantType) {
        var coinsReward = 0
        var energyReward = 0
        
        switch plant {
        case .cloverBase, .cloverRare, .cloverGold:
            coinsReward = Int.random(in: 300...400)
            energyReward = 1
        default:
            coinsReward = Int.random(in: 50...150)
            energyReward = 0
        }
        
        topBar.updateScore(newCoinsCount: coinsReward, newEnergyCount: energyReward)
    }
}
