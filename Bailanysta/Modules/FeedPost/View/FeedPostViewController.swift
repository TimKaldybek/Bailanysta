//
//  FeedPostViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FeedPostViewController: UIViewController {

    var didFinish: (() -> Void)?

    private let presenter: FeedPostPresenter

    private var categoryButtons: [UIButton] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.Title".localized, size: 20, weight: .bold, textColor: Color.label)
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = Color.labelSecondary
        return button
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = Color.label
        textView.backgroundColor = .clear
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.Placeholder".localized, size: 16, weight: .regular, textColor: Color.labelSecondary)
        return label
    }()

    private let categoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private let addMediaButton = FeedPostViewController.makeOutlineButton(
        systemImageName: "photo",
        title: "FeedPost.AddMedia".localized
    )

    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.setText(nil, size: 13, weight: .regular, textColor: Color.labelSecondary)
        label.textAlignment = .center
        return label
    }()

    private let postButton = FeedPostViewController.makeFilledButton(
        systemImageName: "paperplane.fill",
        title: "Feed.Post".localized
    )

    // MARK: - Init

    init(presenter: FeedPostPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()

        presenter.load()
    }
}

// MARK: - FeedPostViewInput

extension FeedPostViewController: FeedPostViewInput {
    func display(_ viewData: FeedPostFormViewData) {
        characterCountLabel.text = viewData.characterCountText
        postButton.isEnabled = viewData.isPostEnabled

        if categoryButtons.isEmpty {
            setupCategoryButtons(count: viewData.categories.count)
        }

        viewData.categories.enumerated().forEach { index, categoryViewData in
            guard categoryButtons.indices.contains(index) else { return }

            let button = categoryButtons[index]
            button.setTitle(categoryViewData.title, for: .normal)
            style(button, isSelected: categoryViewData.isSelected)
        }
    }

    func closeAfterPosting() {
        didFinish?()
    }
}

// MARK: - UITextViewDelegate

extension FeedPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        presenter.textChanged(textView.text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let updatedText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return updatedText.count <= FeedPostFormViewDataFactory.Constants.maxCharacterCount
    }
}

// MARK: - Private

private extension FeedPostViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0

        [titleLabel, closeButton, textView, placeholderLabel, categoryStackView, addMediaButton, characterCountLabel, postButton].forEach {
            view.addSubview($0)
        }

        closeButton.addAction(UIAction { [weak self] _ in
            self?.didFinish?()
        }, for: .touchUpInside)

        postButton.addAction(UIAction { [weak self] _ in
            self?.presenter.postButtonTapped()
        }, for: .touchUpInside)
    }

    func setupCategoryButtons(count: Int) {
        (0..<count).forEach { index in
            let button = FeedPostViewController.makeChipButton()
            button.addAction(UIAction { [weak self] _ in
                self?.presenter.categoryTapped(at: index)
            }, for: .touchUpInside)

            categoryButtons.append(button)
            categoryStackView.addArrangedSubview(button)
        }
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().inset(20)
        }
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(28)
        }
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(140)
        }
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(textView).offset(8)
            $0.leading.equalTo(textView).offset(4)
        }
        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(36)
        }
        addMediaButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(categoryStackView.snp.bottom).offset(24)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            $0.height.equalTo(40)
        }
        postButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(addMediaButton)
            $0.height.equalTo(40)
        }
        characterCountLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(addMediaButton)
        }
    }

    func style(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = Color.primary
            button.setTitleColor(Color.onPrimary, for: .normal)
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(Color.primary, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = Color.primary.cgColor
        }
    }

    static func makeChipButton() -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        return button
    }

    static func makeOutlineButton(systemImageName: String, title: String) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: systemImageName)
        configuration.imagePadding = 6
        configuration.baseForegroundColor = Color.primary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.primary.cgColor
        button.clipsToBounds = true
        return button
    }

    static func makeFilledButton(systemImageName: String, title: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.image = UIImage(systemName: systemImageName)
        configuration.imagePadding = 6
        configuration.baseBackgroundColor = Color.primary
        configuration.baseForegroundColor = Color.onPrimary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 15, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        return button
    }
}
