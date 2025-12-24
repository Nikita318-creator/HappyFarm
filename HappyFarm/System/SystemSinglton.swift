import UIKit
import AVFoundation

final class SystemSinglton {
    static let shared = SystemSinglton()
    
    private var audioPlayer: AVAudioPlayer?
    
    private let soundKey = "isSoundOff"
    private let musicKey = "isMusicOff"
    
    var isSoundOff: Bool {
        didSet {
            UserDefaults.standard.set(isSoundOff, forKey: soundKey)
        }
    }
    
    var isMusicOff: Bool {
        didSet {
            UserDefaults.standard.set(isMusicOff, forKey: musicKey)
            handleMusic()
        }
    }

    private init() {
        self.isSoundOff = UserDefaults.standard.bool(forKey: soundKey)
        self.isMusicOff = UserDefaults.standard.bool(forKey: musicKey)
        
        setupAudioSession()
        setupAudioPlayer()
        setupNotifications()
        handleMusic()
    }
    
    private func setupAudioSession() {
        do {
            // Устанавливаем категорию, которая затихает при переключении бесшумного режима (по желанию)
            // или .playback, если музыка должна играть всегда (но мы ее выключим сами в фоне)
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("LOG: Failed to set audio session category: \(error)")
        }
    }
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "audio1", withExtension: "mp3") else {
            print("LOG: Error - audio1 file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.1
            audioPlayer?.prepareToPlay()
        } catch {
            print("LOG: Player init error: \(error)")
        }
    }
    
    // MARK: - App Lifecycle Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc private func handleAppBackground() {
        // Принудительно ставим на паузу при сворачивании
        print("LOG: App in background - pausing music")
        audioPlayer?.pause()
    }
    
    @objc private func handleAppForeground() {
        // При возврате проверяем, включена ли музыка в настройках
        print("LOG: App in foreground - checking music settings")
        handleMusic()
    }
    
    private func handleMusic() {
        if isMusicOff {
            audioPlayer?.stop()
        } else {
            // Если приложение в фоне, не начинаем играть (на всякий случай)
            if UIApplication.shared.applicationState != .background {
                audioPlayer?.play()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
