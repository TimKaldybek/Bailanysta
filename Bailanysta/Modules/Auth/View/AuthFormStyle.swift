//
//  AuthFormStyle.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Shared button/badge/divider builders for the `Auth` module's Login and SignUp screens.
enum AuthFormStyle {

    static func makeHeroBadge(icon: String) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 40
        container.clipsToBounds = true
        container.snp.makeConstraints {
            $0.size.equalTo(80)
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Color.primary.cgColor, Color.tertiary.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        container.layer.insertSublayer(gradientLayer, at: 0)

        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = Color.onPrimary
        iconImageView.contentMode = .scaleAspectFit
        container.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(36)
        }

        return container
    }

    static func makeFilledButton(title: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = Color.primary
        configuration.baseForegroundColor = Color.onPrimary
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }

    static func makeOutlineButton(title: String, icon: String? = nil) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.baseForegroundColor = Color.label
        configuration.background.backgroundColor = Color.surface
        configuration.background.strokeColor = Color.divider
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 16
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        if let icon {
            configuration.image = UIImage(systemName: icon)
            configuration.imagePadding = 8
            configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        }

        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }

    static func makeTextButton(title: String, color: UIColor = Color.primary) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        return button
    }

    static func makeDivider(text: String) -> UIView {
        let container = UIView()

        let leftLine = UIView()
        leftLine.backgroundColor = Color.divider
        let rightLine = UIView()
        rightLine.backgroundColor = Color.divider

        let label = UILabel()
        label.setText(text, size: 13, weight: .regular, textColor: Color.labelTertiary)

        [leftLine, label, rightLine].forEach { container.addSubview($0) }

        container.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        leftLine.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1)
            $0.trailing.equalTo(label.snp.leading).offset(-12)
        }
        rightLine.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.equalTo(label.snp.trailing).offset(12)
        }

        return container
    }
}
