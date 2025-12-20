import UIKit
import SnapKit

class GardenCell: UICollectionViewCell {
    static let reuseId = "GardenCell"
    
    private let gardenImageView = UIImageView()
    private let timerLabel = UILabel()
    
    private var timer: Timer?
    private var timeLeft: Int = 0
    private var cellIndex: Int = 0
    
    var onGrowthFinished: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupCell() {
        gardenImageView.image = UIImage(named: "garden_img")
        gardenImageView.contentMode = .scaleAspectFit
        contentView.addSubview(gardenImageView)
        gardenImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        timerLabel.textColor = .white
        timerLabel.font = .systemFont(ofSize: 16, weight: .black)
        timerLabel.textAlignment = .center
        
        contentView.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // Вот твой пропавший метод, сука
    func configure(with index: Int) {
        self.cellIndex = index
        // Если таймер не запущен, можно просто очистить текст или поставить ID
        if timer == nil {
            timerLabel.text = ""
        }
    }
    
    func startTimer(seconds: Int) {
        guard timer == nil else { return }
        
        self.timeLeft = seconds
        updateLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        if timeLeft > 0 {
            timeLeft -= 1
            updateLabel()
        } else {
            stopTimer()
            timerLabel.text = "READY!"
            onGrowthFinished?()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateLabel() {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopTimer()
        timerLabel.text = ""
    }
}
