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
        if levelNum <= unlockedLevel {
            let gameVC = GameVC()
            gameVC.currentLevel = indexPath.row
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? LevelCell {
                cell.shake()
            }
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
