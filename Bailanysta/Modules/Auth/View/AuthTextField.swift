//
//  AuthTextField.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Rounded, bordered text field with a leading icon (mirrors `SearchBarView`'s container style) and an
/// optional trailing show/hide toggle for secure entry. Animates its border to `Color.primary` while
/// focused. Shared between `LoginViewController` and `SignUpViewController`.
final class AuthTextField: UIView {

    let textField = UITextField()

    var isEnabled: Bool {
        get { textField.isEnabled }
        set {
            textField.isEnabled = newValue
            alpha = newValue ? 1 : 0.6
        }
    }

    private let iconImageView = UIImageView()
    private let isSecure: Bool
    private var secureToggleButton: UIButton?

    init(
        icon: String,
        placeholder: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) {
        self.isSecure = isSecure
        super.init(frame: .zero)
        setupUI(icon: icon, placeholder: placeholder, keyboardType: keyboardType, textContentType: textContentType)
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func focus() {
        textField.becomeFirstResponder()
    }
}

// MARK: - Private

private extension AuthTextField {
    func setupUI(
        icon: String,
        placeholder: String,
        keyboardType: UIKeyboardType,
        textContentType: UITextContentType?
    ) {
        backgroundColor = Color.surface
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = Color.divider.cgColor

        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = Color.labelTertiary
        iconImageView.contentMode = .scaleAspectFit

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Color.labelTertiary]
        )
        textField.textColor = Color.label
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)

        [iconImageView, textField].forEach { addSubview($0) }

        if isSecure {
            let button = UIButton(type: .system)
            button.tintColor = Color.labelTertiary
            button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            button.addAction(UIAction { [weak self] _ in self?.toggleSecureEntry() }, for: .touchUpInside)
            addSubview(button)
            secureToggleButton = button
        }
    }

    func setupConstraints() {
        snp.makeConstraints {
            $0.height.equalTo(54)
        }
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }

        if let secureToggleButton {
            secureToggleButton.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(12)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(28)
            }
            textField.snp.makeConstraints {
                $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
                $0.trailing.equalTo(secureToggleButton.snp.leading).offset(-8)
                $0.centerY.equalToSuperview()
            }
        } else {
            textField.snp.makeConstraints {
                $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
        }
    }

    @objc func handleEditingDidBegin() {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = Color.primary.cgColor
            self.layer.borderWidth = 1.5
        }
    }

    @objc func handleEditingDidEnd() {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = Color.divider.cgColor
            self.layer.borderWidth = 1
        }
    }

    func toggleSecureEntry() {
        textField.isSecureTextEntry.toggle()
        let symbol = textField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        secureToggleButton?.setImage(UIImage(systemName: symbol), for: .normal)
    }
}
