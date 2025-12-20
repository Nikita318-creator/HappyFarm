import UIKit
import SnapKit

class TrophiesVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let blackOverlay = UIView()
    private let titleImageView = UIImageView()
    private var collectionView: UICollectionView!
    
    private let plants: [PlantType] = {
        let all = PlantType.allCases
        return all.filter { !$0.rawValue.contains("clover") } + all.filter { $0.rawValue.contains("clover") }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        backgroundView.image = UIImage(named: "farm_image")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        blackOverlay.backgroundColor = .black.withAlphaComponent(0.7)
        view.addSubview(blackOverlay)
        blackOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        titleImageView.image = UIImage(named: "TrophiesTitle")
        titleImageView.contentMode = .scaleAspectFit
        view.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(250)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10 // Минимальный зазор между растениями
        // Ячейка почти по размеру растения (200 + запас на текст)
        layout.itemSize = CGSize(width: view.frame.width, height: 220)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false // ОБЫЧНЫЙ СКРОЛЛ
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TrophyCollectionCell.self, forCellWithReuseIdentifier: TrophyCollectionCell.id)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension TrophiesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrophyCollectionCell.id, for: indexPath) as! TrophyCollectionCell
        cell.configure(with: plants[indexPath.row])
        return cell
    }
}
