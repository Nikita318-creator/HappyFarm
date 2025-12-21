import UIKit
import SnapKit

class StoreItemCell: UICollectionViewCell {
    let imgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imgView.contentMode = .scaleAspectFit
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
