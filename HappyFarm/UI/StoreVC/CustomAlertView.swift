import UIKit
import SnapKit

class CustomAlertView: UIView {
    
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    private let confirmBtn = UIButton()
    private let cancelBtn = UIButton()
    
    init(title: String, message: String, isError: Bool = false) {
        super.init(frame: .zero)
        setupUI(title: title, message: message, isError: isError)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI(title: String, message: String, isError: Bool) {
        self.backgroundColor = .black.withAlphaComponent(0.8)
        
        container.backgroundColor = UIColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1.0) // Темно-коричневый "фермерский"
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 3
        container.layer.borderColor = UIColor.orange.cgColor
        addSubview(container)
        
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
        }
        
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 22, weight: .black)
        titleLabel.textColor = .orange
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        container.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        container.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        if !isError {
            cancelBtn.setTitle("CANCEL", for: .normal)
            cancelBtn.backgroundColor = .systemGray
            cancelBtn.layer.cornerRadius = 10
            cancelBtn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
            stackView.addArrangedSubview(cancelBtn)
        }
        
        confirmBtn.setTitle(isError ? "GOT IT" : "CONTINUE", for: .normal)
        confirmBtn.backgroundColor = .orange
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        stackView.addArrangedSubview(confirmBtn)
    }
    
    @objc private func handleConfirm() { onConfirm?(); removeFromSuperview() }
    @objc private func handleCancel() { onCancel?(); removeFromSuperview() }
    
    func show(on view: UIView) {
        self.alpha = 0
        view.addSubview(self)
        self.snp.makeConstraints { $0.edges.equalToSuperview() }
        UIView.animate(withDuration: 0.3) { self.alpha = 1 }
    }
}
