import UIKit
import SnapKit

class TrophyCollectionCell: UICollectionViewCell {
    static let id = "TrophyCollectionCell"
    
    private let plantIcon = UIImageView()
    private let countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupCell() {
        plantIcon.contentMode = .scaleAspectFit
        contentView.addSubview(plantIcon)
        
        plantIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200) // Размер растения
        }
        
        countLabel.textColor = .white
        countLabel.font = .systemFont(ofSize: 20, weight: .black)
        contentView.addSubview(countLabel)
        
        countLabel.snp.makeConstraints { make in
            make.trailing.equalTo(plantIcon.snp.trailing).offset(5)
            make.bottom.equalTo(plantIcon.snp.bottom).offset(5)
        }
    }
    
    func configure(with type: PlantType) {
        plantIcon.image = UIImage(named: type.rawValue + "_full")
        let key = "trophy_count_\(type.rawValue)"
        let count = UserDefaults.standard.integer(forKey: key)
        countLabel.text = "x\(count)"
    }
}
