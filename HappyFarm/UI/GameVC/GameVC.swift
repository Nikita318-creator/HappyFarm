import UIKit
import SnapKit

class GameVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let topBar = GameTopBar()
    private let growthTimes = [10, 20, 30, 60, 90, 120, 300, 300, 300]
    
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
        if let cell = collectionView.cellForItem(at: indexPath) as? GardenCell {
            let time = growthTimes[indexPath.row]
            
            print("Запуск роста на грядке \(indexPath.row) на \(time) сек")
            
            cell.startTimer(seconds: time)
            cell.onGrowthFinished = {
                print("Грядка \(indexPath.row) принесла урожай! Хий.")
            }
        }
    }
}
