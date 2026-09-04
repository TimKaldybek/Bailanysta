//
//  CommentsComposeView.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Нижняя панель ввода комментария: текстовое поле в "пилюле" + круглая кнопка отправки
final class CommentsComposeView: UIView {

    var onSendTapped: ((String) -> Void)?

    private let inputPill: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 20
        return view
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Comments.Placeholder".localized
        textField.textColor = Color.label
        textField.font = .systemFont(ofSize: 15, weight: .regular)
        textField.returnKeyType = .send
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = Color.labelTertiary
        button.isEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Public

    func setEnabled(_ isEnabled: Bool) {
        textField.isEnabled = isEnabled
        alpha = isEnabled ? 1 : 0.6
        updateSendButtonState()
    }

    func clearInput() {
        textField.text = nil
        updateSendButtonState()
    }
}

// MARK: - Private

private extension CommentsComposeView {
    func setupSubviews() {
        inputPill.addSubview(textField)
        [inputPill, sendButton].forEach { addSubview($0) }

        textField.addAction(UIAction { [weak self] _ in
            self?.updateSendButtonState()
        }, for: .editingChanged)

        textField.addAction(UIAction { [weak self] _ in
            self?.handleSend()
        }, for: .primaryActionTriggered)

        sendButton.addAction(UIAction { [weak self] _ in
            self?.handleSend()
        }, for: .touchUpInside)
    }

    func setupConstraints() {
        inputPill.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
        textField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview()
        }
        sendButton.snp.makeConstraints {
            $0.leading.equalTo(inputPill.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(inputPill)
            $0.size.equalTo(36)
        }
    }

    func handleSend() {
        guard let text = textField.text, !text.isEmpty else { return }
        onSendTapped?(text)
    }

    func updateSendButtonState() {
        let isEnabled = textField.isEnabled && !(textField.text ?? "").isEmpty
        sendButton.isEnabled = isEnabled
        sendButton.tintColor = isEnabled ? Color.primary : Color.labelTertiary
    }
}
