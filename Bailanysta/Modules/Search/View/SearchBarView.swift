//
//  SearchBarView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class SearchBarView: UIView {
    var onSubmit: ((String) -> Void)?
    /// Голосовой поиск пока не реализован — тап по иконке используется как точка входа для заглушки
    var onMicTapped: (() -> Void)?

    private let searchIconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = Color.labelTertiary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let textField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: "Search.Placeholder".localized,
            attributes: [.foregroundColor: Color.labelTertiary]
        )
        field.textColor = Color.label
        field.font = .systemFont(ofSize: 15, weight: .regular)
        field.returnKeyType = .search
        return field
    }()

    private let micIconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mic.fill"))
        iv.tintColor = Color.labelTertiary
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        textField.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setText(_ text: String) {
        textField.text = text
    }

    private func setupUI() {
        backgroundColor = Color.surface
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = Color.divider.cgColor

        micIconImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleMicTapped))
        )

        [searchIconImageView, textField, micIconImageView].forEach { addSubview($0) }
    }

    @objc private func handleMicTapped() {
        onMicTapped?()
    }

    private func setupConstraints() {
        searchIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        micIconImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        textField.snp.makeConstraints {
            $0.leading.equalTo(searchIconImageView.snp.trailing).offset(10)
            $0.trailing.equalTo(micIconImageView.snp.leading).offset(-10)
            $0.top.bottom.equalToSuperview()
        }
        snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSubmit?(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}
