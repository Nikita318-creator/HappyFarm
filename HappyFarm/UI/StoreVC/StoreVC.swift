import UIKit
import SnapKit

class StoreVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let blackOverlay = UIView()
    private let titleImageView = UIImageView()
    private let backBtn = UIButton()
    
    private let coinBg = UIImageView(image: UIImage(named: "score_bg"))
    private let coinIcon = UIImageView(image: UIImage(named: "coin_icon"))
    private let coinLabel = UILabel()
    
    private var collectionView: UICollectionView!
    private let itemImages = ["store_item1", "store_item2", "store_item3", "store_item4"]
    private let prices = [1000, 1300, 3000, 5000]
    
    private let coinsKey = "user_coins_count"
    private let purchasedKey = "purchased_items_ids"
    
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
        
        titleImageView.image = UIImage(named: "STORE_title")
        titleImageView.contentMode = .scaleAspectFit
        view.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        updateCoinsUI()
        coinLabel.textColor = .white
        coinLabel.font = .systemFont(ofSize: 22, weight: .black)
        
        view.addSubview(coinBg)
        coinBg.addSubview(coinIcon)
        coinBg.addSubview(coinLabel)
        
        coinBg.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(45)
        }
        
        coinIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        coinLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        backBtn.setBackgroundImage(UIImage(named: "close_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.size.equalTo(105)
        }
        
        let layout = UICollectionViewFlowLayout()
        let sidePadding: CGFloat = 25
        let itemWidth = (view.frame.width - (sidePadding * 3)) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        layout.minimumInteritemSpacing = sidePadding
        layout.minimumLineSpacing = sidePadding
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(StoreItemCell.self, forCellWithReuseIdentifier: "StoreItemCell")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(coinBg.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(sidePadding)
            make.bottom.equalTo(backBtn.snp.top).offset(-10)
        }
    }
    
    private func updateCoinsUI() {
        let coinsValue = UserDefaults.standard.integer(forKey: coinsKey)
        coinLabel.text = "\(coinsValue)"
    }
    
    @objc private func handleBack() {
        self.dismiss(animated: true)
    }
}

extension StoreVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreItemCell", for: indexPath) as! StoreItemCell
        cell.imgView.image = UIImage(named: itemImages[indexPath.row])
        
        let purchasedIDs = UserDefaults.standard.array(forKey: purchasedKey) as? [Int] ?? []
        if purchasedIDs.contains(indexPath.row) {
            cell.contentView.alpha = 0.5
            cell.isUserInteractionEnabled = false
        } else {
            cell.contentView.alpha = 1.0
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alert = CustomAlertView(
            title: "Want to buy?",
            message: "This item increases growth speed and gives more chances to get a Luck Clover!"
        )
        
        alert.onConfirm = { [weak self] in
            self?.processPurchase(index: indexPath.row, price: self?.prices[indexPath.row] ?? 0)
        }
        
        alert.show(on: self.view)
    }
    
    private func processPurchase(index: Int, price: Int) {
        let currentCoins = UserDefaults.standard.integer(forKey: coinsKey)
        
        if currentCoins >= price {
            let newBalance = currentCoins - price
            UserDefaults.standard.set(newBalance, forKey: coinsKey)
            
            var purchasedIDs = UserDefaults.standard.array(forKey: purchasedKey) as? [Int] ?? []
            purchasedIDs.append(index)
            UserDefaults.standard.set(purchasedIDs, forKey: purchasedKey)
            
            UserDefaults.standard.synchronize()
            
            updateCoinsUI()
            collectionView.reloadData()
        } else {
            let errorAlert = CustomAlertView(
                title: "No coins!",
                message: "Keep harvesting to save up for this item!",
                isError: true
            )
            errorAlert.show(on: self.view)
        }
    }
}
