//
//  FeedPostViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit
import PhotosUI

final class FeedPostViewController: UIViewController {

    var didFinish: (() -> Void)?

    private let presenter: FeedPostPresenter

    private var categoryButtons: [UIButton] = []
    private var maxCharacterCount = Int.max
    private var remainingAttachmentSlots = 0

    /// Last attachment set actually rendered — lets `display(_:)` skip rebuilding the (expensive,
    /// full-resolution image) thumbnail row on pushes that only changed unrelated form state, e.g.
    /// every keystroke in the text view.
    private var renderedAttachmentIDs: [UUID] = []
    private var renderedIsAddPhotoEnabled = false

    // MARK: - Header

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.Title".localized, size: 20, weight: .bold, textColor: Color.label)
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = Color.labelSecondary
        button.backgroundColor = Color.primaryMuted
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        return button
    }()

    // MARK: - Scroll content

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        return stack
    }()

    // MARK: - Composer card

    private let composerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        view.layer.cornerRadius = 20
        return view
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = Color.label
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.Placeholder".localized, size: 16, weight: .regular, textColor: Color.labelTertiary)
        return label
    }()

    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.setText(nil, size: 12, weight: .medium, textColor: Color.labelSecondary)
        return label
    }()

    // MARK: - Photos section

    private let photosHeaderLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.Photos".localized, size: 15, weight: .semibold, textColor: Color.label)
        return label
    }()

    private let attachmentsCountLabel: UILabel = {
        let label = UILabel()
        label.setText(nil, size: 13, weight: .regular, textColor: Color.labelSecondary)
        return label
    }()

    private let attachmentsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let attachmentsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()

    private let addPhotoTileButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus")
        configuration.baseForegroundColor = Color.primary
        let button = UIButton(configuration: configuration)
        button.backgroundColor = Color.primaryMuted
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.accessibilityLabel = "FeedPost.AddMedia".localized
        return button
    }()

    // MARK: - Category section

    private let categoryHeaderLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.Category".localized, size: 15, weight: .semibold, textColor: Color.label)
        return label
    }()

    private let categoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    // MARK: - Bottom bar

    private let bottomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.divider
        return view
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
        maxCharacterCount = viewData.maxCharacterCount
        remainingAttachmentSlots = viewData.remainingAttachmentSlots

        characterCountLabel.text = viewData.characterCountText
        characterCountLabel.textColor = viewData.isCharacterCountNearLimit ? Color.accentRed : Color.labelSecondary

        attachmentsCountLabel.text = viewData.attachmentsCountText

        postButton.isEnabled = viewData.isPostEnabled
        postButton.configuration?.showsActivityIndicator = viewData.isSubmitting
        postButton.configuration?.title = viewData.isSubmitting
            ? "FeedPost.Posting".localized
            : "Feed.Post".localized
        closeButton.isEnabled = !viewData.isSubmitting

        if categoryButtons.isEmpty {
            setupCategoryButtons(count: viewData.categories.count)
        }

        viewData.categories.enumerated().forEach { index, categoryViewData in
            guard categoryButtons.indices.contains(index) else { return }

            let button = categoryButtons[index]
            button.setTitle(categoryViewData.title, for: .normal)
            button.isEnabled = !viewData.isSubmitting
            style(button, isSelected: categoryViewData.isSelected)
        }

        updateAttachmentsIfNeeded(viewData)

        if let errorMessage = viewData.errorMessage {
            showAlert(title: "Error".localized, message: errorMessage)
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
        return updatedText.count <= maxCharacterCount
    }
}

// MARK: - PHPickerViewControllerDelegate

extension FeedPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        Task { @MainActor in
            let images = await Self.loadImages(from: results)
            presenter.imagesPicked(images)
        }
    }
}

// MARK: - Private

private extension FeedPostViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        textView.delegate = self

        composerCardView.addSubview(textView)
        composerCardView.addSubview(placeholderLabel)
        composerCardView.addSubview(characterCountLabel)

        attachmentsScrollView.addSubview(attachmentsStackView)

        let photosHeaderRow = UIStackView(arrangedSubviews: [photosHeaderLabel, attachmentsCountLabel])
        photosHeaderRow.axis = .horizontal
        photosHeaderRow.distribution = .equalSpacing

        let photosSectionStack = UIStackView(arrangedSubviews: [photosHeaderRow, attachmentsScrollView])
        photosSectionStack.axis = .vertical
        photosSectionStack.spacing = 12

        let categorySectionStack = UIStackView(arrangedSubviews: [categoryHeaderLabel, categoryStackView])
        categorySectionStack.axis = .vertical
        categorySectionStack.spacing = 12

        [composerCardView, photosSectionStack, categorySectionStack].forEach {
            contentStackView.addArrangedSubview($0)
        }

        scrollView.addSubview(contentStackView)

        [titleLabel, closeButton, scrollView, bottomDivider, postButton].forEach {
            view.addSubview($0)
        }

        closeButton.addAction(UIAction { [weak self] _ in
            self?.didFinish?()
        }, for: .touchUpInside)

        postButton.addAction(UIAction { [weak self] _ in
            self?.presenter.postButtonTapped()
        }, for: .touchUpInside)

        addPhotoTileButton.addAction(UIAction { [weak self] _ in
            self?.presentPhotoPicker()
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

    func updateAttachmentsIfNeeded(_ viewData: FeedPostFormViewData) {
        let attachmentIDs = viewData.attachments.map(\.id)
        guard attachmentIDs != renderedAttachmentIDs || viewData.isAddPhotoEnabled != renderedIsAddPhotoEnabled else {
            return
        }
        renderedAttachmentIDs = attachmentIDs
        renderedIsAddPhotoEnabled = viewData.isAddPhotoEnabled

        attachmentsStackView.arrangedSubviews.forEach {
            attachmentsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        viewData.attachments.enumerated().forEach { index, attachment in
            let thumbnail = FeedPostAttachmentThumbnailView(image: attachment.image)
            thumbnail.removeTapped = { [weak self] in
                self?.presenter.removeAttachment(at: index)
            }
            attachmentsStackView.addArrangedSubview(thumbnail)
        }

        if viewData.isAddPhotoEnabled {
            attachmentsStackView.addArrangedSubview(addPhotoTileButton)
        }
    }

    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = max(1, remainingAttachmentSlots)

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    static func loadImages(from results: [PHPickerResult]) async -> [UIImage] {
        await withTaskGroup(of: UIImage?.self) { group in
            for result in results {
                group.addTask {
                    await withCheckedContinuation { continuation in
                        guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                            continuation.resume(returning: nil)
                            return
                        }
                        result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                            continuation.resume(returning: object as? UIImage)
                        }
                    }
                }
            }

            var images: [UIImage] = []
            for await image in group {
                if let image {
                    images.append(image)
                }
            }
            return images
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

        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomDivider.snp.top)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        textView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(110)
        }
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(textView)
            $0.leading.equalTo(textView)
        }
        characterCountLabel.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        attachmentsScrollView.snp.makeConstraints {
            $0.height.equalTo(76)
        }
        attachmentsStackView.snp.makeConstraints {
            $0.edges.height.equalToSuperview()
        }
        addPhotoTileButton.snp.makeConstraints {
            $0.size.equalTo(76)
        }

        categoryStackView.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        bottomDivider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalTo(postButton.snp.top).offset(-12)
        }
        postButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12)
            $0.height.equalTo(50)
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
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        return button
    }
}
