import UIKit
import SnapKit
import AudioToolbox // 1. Импортируем для звуков

enum PlantType: String, CaseIterable {
    case carrot = "plant_carrot"
    case onion = "plant_onion"
    case corn = "plant_corn"
    case pineapple = "plant_pineapple"
    case cabbage = "plant_cabbage"
    case cloverBase = "clover_standard"
    case cloverRare = "clover_dark"
    case cloverGold = "clover_gold"
}

class GardenCell: UICollectionViewCell {
    static let reuseId = "GardenCell"
    
    private let gardenImageView = UIImageView()
    private let plantImageView = UIImageView()
    private let timerLabel = UILabel()
    
    private var timer: Timer?
    private var timeLeft: Int = 0
    
    private(set) var isReady: Bool = false
    private(set) var currentPlant: PlantType?
    var onGrowthFinished: ((PlantType) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func playSound(id: SystemSoundID) {
        if !SystemSinglton.shared.isSoundOff {
            AudioServicesPlaySystemSound(id)
        }
    }
    
    private func setupCell() {
        gardenImageView.image = UIImage(named: "garden_img")
        gardenImageView.contentMode = .scaleAspectFit
        contentView.addSubview(gardenImageView)
        gardenImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        plantImageView.contentMode = .scaleAspectFit
        plantImageView.isHidden = true
        contentView.addSubview(plantImageView)
        plantImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
            make.size.equalToSuperview().multipliedBy(0.7)
        }
        
        timerLabel.textColor = .white
        timerLabel.font = .systemFont(ofSize: 16, weight: .black)
        contentView.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    func configure(with index: Int) {}
    
    func startTimer(seconds: Int) {
        guard timer == nil else { return }
        
        playSound(id: 1104)
        
        plantImageView.isHidden = true
        timerLabel.isHidden = false
        
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
            finishGrowth()
        }
    }
    
    private func finishGrowth() {
        timer?.invalidate()
        timer = nil
        timerLabel.isHidden = true
        
        playSound(id: 1111)
        
        let result = getRandomPlant()
        currentPlant = result
        isReady = true
        
        plantImageView.image = UIImage(named: result.rawValue)
        plantImageView.isHidden = false
        
        plantImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3) {
            self.plantImageView.transform = .identity
        }
        
        onGrowthFinished?(result)
    }
    
    func harvest() -> PlantType? {
        playSound(id: 1103)
        
        let plant = currentPlant
        isReady = false
        currentPlant = nil
        plantImageView.isHidden = true
        timerLabel.text = ""
        timerLabel.isHidden = false
        return plant
    }
    
    private func getRandomPlant() -> PlantType {
        let roll = Int.random(in: 1...100)
        switch roll {
        case 1: return .cloverGold
        case 2...5: return .cloverRare
        case 6...15: return .cloverBase
        default:
            let veggies: [PlantType] = [.carrot, .onion, .corn, .pineapple, .cabbage]
            return veggies.randomElement() ?? .carrot
        }
    }
    
    private func updateLabel() {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
        timer = nil
        plantImageView.isHidden = true
        timerLabel.text = ""
    }
}
