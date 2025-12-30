import UIKit
import SnapKit

struct StorySlide {
    let text: String
    let imageName: String
}

class StoryVC: UIViewController {
    
    var slides: [StorySlide] = []
    var onStoryFinished: (() -> Void)?
    
    private var currentStep = 0
    private let backgroundImageView = UIImageView()
    private let characterImageView = UIImageView()
    private let textContainer = UIView()
    private let storyLabel = UILabel()
    private let nextButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesture() // Добавляем распознаватель тапа
        updateContent()
    }
    
    private func setupGesture() {
        // Создаем жест тапа на всю вьюху
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        characterImageView.contentMode = .scaleAspectFit
        view.addSubview(characterImageView)
        characterImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(100)
            make.left.equalToSuperview().offset(-20)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        textContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        textContainer.layer.cornerRadius = 20
        textContainer.layer.borderWidth = 2
        textContainer.layer.borderColor = UIColor.systemOrange.cgColor
        textContainer.isUserInteractionEnabled = false // Пропускаем нажатия сквозь контейнер к основной вью
        view.addSubview(textContainer)
        textContainer.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(150)
        }
        
        storyLabel.textColor = .white
        storyLabel.font = .systemFont(ofSize: 18, weight: .bold)
        storyLabel.numberOfLines = 0
        textContainer.addSubview(storyLabel)
        storyLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        nextButton.setTitle("TAP TO CONTINUE >>>", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .black)
        nextButton.setTitleColor(.systemOrange, for: .normal)
        nextButton.isUserInteractionEnabled = false // Чтобы кнопка не блокировала жест основной вью
        
        nextButton.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        nextButton.titleLabel?.layer.shadowOffset = CGSize(width: 4, height: 4)
        nextButton.titleLabel?.layer.shadowRadius = 2.0
        nextButton.titleLabel?.layer.shadowOpacity = 1
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(textContainer.snp.top).offset(-10)
            make.right.equalTo(textContainer)
        }
    }
    
    @objc private func nextTapped() {
        currentStep += 1
        if currentStep < slides.count {
            updateContent()
        } else {
            self.dismiss(animated: true) {
                self.onStoryFinished?()
            }
        }
    }
    
    private func updateContent() {
        guard currentStep < slides.count else { return }
        let slide = slides[currentStep]
        storyLabel.text = slide.text
        backgroundImageView.image = UIImage(named: slide.imageName)
        
        storyLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.storyLabel.alpha = 1
        }
    }
}
