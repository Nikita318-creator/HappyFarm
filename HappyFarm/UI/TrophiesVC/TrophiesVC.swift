import UIKit
import SnapKit

class TrophiesVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let blackOverlay = UIView()
    private let titleImageView = UIImageView()
    private var collectionView: UICollectionView!
    private let backBtn = UIButton() // Добавили кнопку
    
    private let plants: [PlantType] = {
        let all = PlantType.allCases
        return all.filter { !$0.rawValue.contains("clover") } + all.filter { $0.rawValue.contains("clover") }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        backgroundView.image = UIImage(named: "backgraundImg")
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
        
        // Кнопка BACK (как в PauseView)
        backBtn.setBackgroundImage(UIImage(named: "close_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        view.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.size.equalTo(105) // Тот самый размер 105
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: view.frame.width, height: 220)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TrophyCollectionCell.self, forCellWithReuseIdentifier: TrophyCollectionCell.id)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(backBtn.snp.top).offset(-10) // Коллекция заканчивается над кнопкой
        }
    }
    
    @objc private func handleBack() {
        self.dismiss(animated: true)
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
