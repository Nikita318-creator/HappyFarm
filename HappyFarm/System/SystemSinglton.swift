import UIKit
import AVFoundation

class SystemSinglton {
    static let shared = SystemSinglton()
    
    private var audioPlayer: AVAudioPlayer?
    
    // Ключи из UserDefaults для синхронизации
    private let soundKey = "isSoundOff"
    private let musicKey = "isMusicOff"
    
    var isSoundOff: Bool {
        didSet {
            UserDefaults.standard.set(isSoundOff, forKey: soundKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isMusicOff: Bool {
        didSet {
            UserDefaults.standard.set(isMusicOff, forKey: musicKey)
            UserDefaults.standard.synchronize()
            handleMusic()
        }
    }

    private init() {
        // Загружаем сохраненные состояния сразу
        self.isSoundOff = UserDefaults.standard.bool(forKey: soundKey)
        self.isMusicOff = UserDefaults.standard.bool(forKey: musicKey)
        
        setupAudioPlayer()
        handleMusic()
    }
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "audio1", withExtension: "mp3") else {
            print("Ошибка: файл audio1 не найден")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Бесконечно
            audioPlayer?.volume = 0.1 // Минимальная громкость
            audioPlayer?.prepareToPlay()
        } catch {
            print("Ошибка инициализации плеера: \(error)")
        }
    }
    
    private func handleMusic() {
        if isMusicOff {
            audioPlayer?.stop()
        } else {
            audioPlayer?.play()
        }
    }
}
