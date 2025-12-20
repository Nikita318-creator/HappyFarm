import UIKit
import SnapKit

class PauseView: UIView {
    
    var onMenuTapped: (() -> Void)?
    var onCloseTapped: (() -> Void)?
    
    private let titleImageView = UIImageView()
    private let soundBtn = UIButton()
    private let musicBtn = UIButton()
    private let menuBtn = UIButton()
    private let closeBtn = UIButton()
    
    private var isSoundActive = !SystemSinglton.shared.isSoundOff
    private var isMusicActive = !SystemSinglton.shared.isMusicOff
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        self.backgroundColor = .black.withAlphaComponent(0.8)
        
        // Настройка картинки-заголовка
        titleImageView.image = UIImage(named: "PAUSE")
        titleImageView.contentMode = .scaleAspectFit
        
        // Настройка кнопок
        soundBtn.setBackgroundImage(UIImage(named: isSoundActive ? "sound_on" : "sound_off"), for: .normal)
        soundBtn.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
        
        musicBtn.setBackgroundImage(UIImage(named: isMusicActive ? "music_on" : "music_off"), for: .normal)
        musicBtn.addTarget(self, action: #selector(toggleMusic), for: .touchUpInside)
        
        menuBtn.setBackgroundImage(UIImage(named: "menu_btn"), for: .normal)
        menuBtn.addTarget(self, action: #selector(handleMenu), for: .touchUpInside)
        
        closeBtn.setBackgroundImage(UIImage(named: "close_btn"), for: .normal)
        closeBtn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        [titleImageView, soundBtn, musicBtn, menuBtn, closeBtn].forEach { addSubview($0) }
        
        let commonWidth: CGFloat = 180
        
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaInsets).offset(150)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
        
        soundBtn.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(commonWidth)
            make.height.equalTo(commonWidth * 0.4)
        }
        
        musicBtn.snp.makeConstraints { make in
            make.top.equalTo(soundBtn.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(commonWidth)
            make.height.equalTo(commonWidth * 0.4)
        }
        
        menuBtn.snp.makeConstraints { make in
            make.top.equalTo(musicBtn.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(commonWidth)
            make.height.equalTo(commonWidth * 0.45)
        }
        
        // Кнопка BACK остается большой (105)
        closeBtn.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
            make.centerX.equalToSuperview()
            make.size.equalTo(105)
        }
    }
    
    @objc private func toggleSound() {
        isSoundActive.toggle()
        let imgName = isSoundActive ? "sound_on" : "sound_off"
        soundBtn.setBackgroundImage(UIImage(named: imgName), for: .normal)
        
        SystemSinglton.shared.isSoundOff = !isSoundActive
    }
    
    @objc private func toggleMusic() {
        isMusicActive.toggle()
        let imgName = isMusicActive ? "music_on" : "music_off"
        musicBtn.setBackgroundImage(UIImage(named: imgName), for: .normal)
        
        SystemSinglton.shared.isMusicOff = !isMusicActive
    }
    
    @objc private func handleMenu() {
        onMenuTapped?()
    }
    
    @objc private func handleClose() {
        onCloseTapped?()
    }
}
