import UIKit
import SnapKit

class HomeVC: UIViewController {
    
    private let backgroundView = UIImageView()
    private let topImageView = UIImageView()
    
    private let playBtn = UIButton()
    private let rulesBtn = UIButton()
    private let storeBtn = UIButton()
    private let trophiesBtn = UIButton()
    private let exitBtn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTargets()
        
        let _ = SystemSinglton.shared
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 1. Фон (Добавляем первым!)
        backgroundView.image = UIImage(named: "backgraundImg")
        backgroundView.contentMode = .scaleAspectFill
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 2. Верхняя картинка
        topImageView.image = UIImage(named: "homeTopImg")
        topImageView.contentMode = .scaleAspectFit
        view.addSubview(topImageView)
        topImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 3. Добавляем кнопки (Обязательно ПОСЛЕ фона)
        let btns = [playBtn, rulesBtn, storeBtn, trophiesBtn, exitBtn]
        let assetNames = ["PLAY", "RULES", "STORE", "TROPHIES", "EXIT"]
        
        for (index, btn) in btns.enumerated() {
            view.addSubview(btn)
            btn.setBackgroundImage(UIImage(named: assetNames[index]), for: .normal)
            btn.snp.makeConstraints { make in
                make.size.equalTo(110)
            }
        }
        
        // 4. Расставляем крестом от центральной кнопки PLAY
        playBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(160)
        }
        
        rulesBtn.snp.makeConstraints { make in
            make.bottom.equalTo(playBtn.snp.top).offset(-15)
            make.centerX.equalToSuperview()
        }
        
        storeBtn.snp.makeConstraints { make in
            make.right.equalTo(playBtn.snp.left).offset(-15)
            make.centerY.equalTo(playBtn)
        }
        
        trophiesBtn.snp.makeConstraints { make in
            make.left.equalTo(playBtn.snp.right).offset(15)
            make.centerY.equalTo(playBtn)
        }
        
        exitBtn.snp.makeConstraints { make in
            make.top.equalTo(playBtn.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTargets() {
        playBtn.addTarget(self, action: #selector(playTap), for: .touchUpInside)
        rulesBtn.addTarget(self, action: #selector(rulesTap), for: .touchUpInside)
        storeBtn.addTarget(self, action: #selector(storeTap), for: .touchUpInside)
        trophiesBtn.addTarget(self, action: #selector(trophiesTap), for: .touchUpInside)
        exitBtn.addTarget(self, action: #selector(exitTap), for: .touchUpInside)
    }
    
    @objc private func playTap() {
        let vc = GameVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @objc private func rulesTap() { print("Tap RULES") }
    @objc private func storeTap() { print("Tap STORE") }
    @objc private func trophiesTap() {
        let vc = TrophiesVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @objc private func exitTap() { exit(0) }
}
