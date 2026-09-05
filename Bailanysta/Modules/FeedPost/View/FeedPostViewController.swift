//
//  FeedPostViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit
import PhotosUI
import AVFoundation

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

    /// Last voice message URL actually configured into `voicePlayerView` — lets `display(_:)` skip
    /// re-creating the `AVPlayer` (which would interrupt any in-progress preview playback) on
    /// pushes unrelated to the voice message, e.g. every keystroke in the text view.
    private var renderedVoiceMessageURL: URL?

    private var audioRecorder: AVAudioRecorder?
    private var recordingStartDate: Date?
    private var recordingTimer: Timer?

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

    // MARK: - Voice message section

    private let voiceHeaderLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.VoiceMessage".localized, size: 15, weight: .semibold, textColor: Color.label)
        return label
    }()
    
    private let voiceHintLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedPost.VoiceMessage.Hint".localized, size: 13, weight: .regular, textColor: Color.labelSecondary)
        label.numberOfLines = 0
        return label
    }()

    private let recordButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = Color.primaryMuted
        configuration.baseForegroundColor = Color.primary
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()

    private let voicePlayerView = VoiceMessagePlayerView()

    private let removeVoiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = Color.labelSecondary
        button.accessibilityLabel = "FeedPost.RemoveVoiceMessage".localized
        return button
    }()

    private lazy var voicePreviewStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [voicePlayerView, removeVoiceButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
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

    deinit {
        // Safety net for a recording still in progress when this screen is dismissed (e.g. a
        // swipe-to-dismiss that bypasses `closeButton`) — an orphaned `AVAudioRecorder` would
        // otherwise keep the mic session active and its repeating elapsed-time `Timer` firing
        // indefinitely.
        recordingTimer?.invalidate()
        if let recorder = audioRecorder {
            recorder.stop()
            try? FileManager.default.removeItem(at: recorder.url)
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }

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
        updateVoiceMessageIfNeeded(viewData)

        if let errorMessage = viewData.errorMessage {
            showAlert(title: "Error".localized, message: errorMessage)
        }
    }

    func closeAfterPosting() {
        // The recording's already been read and uploaded by now — its local temp copy is dead weight.
        if let url = renderedVoiceMessageURL {
            try? FileManager.default.removeItem(at: url)
        }
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

        let voiceSectionStack = UIStackView(
            arrangedSubviews: [voiceHeaderLabel, voiceHintLabel, recordButton, voicePreviewStack]
        )
        voiceSectionStack.axis = .vertical
        voiceSectionStack.alignment = .leading
        voiceSectionStack.spacing = 12
        voiceSectionStack.setCustomSpacing(4, after: voiceHeaderLabel)
        voiceHintLabel.snp.makeConstraints {
            $0.width.equalTo(voiceSectionStack)
        }

        let categorySectionStack = UIStackView(arrangedSubviews: [categoryHeaderLabel, categoryStackView])
        categorySectionStack.axis = .vertical
        categorySectionStack.spacing = 12

        [composerCardView, photosSectionStack, voiceSectionStack, categorySectionStack].forEach {
            contentStackView.addArrangedSubview($0)
        }

        scrollView.addSubview(contentStackView)

        [titleLabel, closeButton, scrollView, bottomDivider, postButton].forEach {
            view.addSubview($0)
        }

        closeButton.addAction(UIAction { [weak self] _ in
            self?.discardVoiceMessageWork()
            self?.didFinish?()
        }, for: .touchUpInside)

        postButton.addAction(UIAction { [weak self] _ in
            self?.presenter.postButtonTapped()
        }, for: .touchUpInside)

        addPhotoTileButton.addAction(UIAction { [weak self] _ in
            self?.presentPhotoPicker()
        }, for: .touchUpInside)

        recordButton.addAction(UIAction { [weak self] _ in
            self?.toggleRecording()
        }, for: .touchUpInside)

        removeVoiceButton.addAction(UIAction { [weak self] _ in
            self?.voicePlayerView.stopPlayback()
            if let url = self?.renderedVoiceMessageURL {
                try? FileManager.default.removeItem(at: url)
            }
            self?.presenter.removeVoiceMessage()
        }, for: .touchUpInside)

        setRecordButtonIdle()
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

    func updateVoiceMessageIfNeeded(_ viewData: FeedPostFormViewData) {
        recordButton.isEnabled = viewData.isRecordVoiceEnabled
        recordButton.isHidden = viewData.voiceMessage != nil
        voiceHintLabel.isHidden = viewData.voiceMessage != nil

        guard let voiceMessage = viewData.voiceMessage else {
            voicePreviewStack.isHidden = true
            renderedVoiceMessageURL = nil
            return
        }

        voicePreviewStack.isHidden = false
        guard voiceMessage.fileURL != renderedVoiceMessageURL else { return }
        renderedVoiceMessageURL = voiceMessage.fileURL
        voicePlayerView.configure(url: voiceMessage.fileURL, duration: voiceMessage.duration)
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

    // MARK: - Voice recording

    func toggleRecording() {
        audioRecorder == nil ? startRecording() : stopRecording()
    }

    func startRecording() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard granted else {
                    self?.showAlert(title: "Error".localized, message: "FeedPost.Error.MicrophoneDenied".localized)
                    return
                }
                self?.beginRecording()
            }
        }
    }

    func beginRecording() {
        let session = AVAudioSession.sharedInstance()
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder.record()
            audioRecorder = recorder
            recordingStartDate = Date()
            setRecordButtonRecording(elapsed: 0)
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                self?.updateRecordingElapsed()
            }
        } catch {
            showAlert(title: "Error".localized, message: "FeedPost.Error.RecordingFailed".localized)
        }
    }

    func updateRecordingElapsed() {
        guard let recordingStartDate else { return }
        setRecordButtonRecording(elapsed: Date().timeIntervalSince(recordingStartDate))
    }

    func stopRecording() {
        guard let recorder = audioRecorder else { return }

        let duration = recorder.currentTime
        recorder.stop()
        audioRecorder = nil
        recordingStartDate = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        setRecordButtonIdle()

        guard duration >= Constants.minimumRecordingDuration else {
            try? FileManager.default.removeItem(at: recorder.url)
            return
        }
        presenter.voiceMessageRecorded(fileURL: recorder.url, duration: duration)
    }

    /// Stops any in-progress recording and discards any already-recorded-but-unposted voice
    /// message's local temp file — called when the composer is closed without posting.
    func discardVoiceMessageWork() {
        if let recorder = audioRecorder {
            recordingTimer?.invalidate()
            recordingTimer = nil
            recorder.stop()
            audioRecorder = nil
            try? FileManager.default.removeItem(at: recorder.url)
            try? AVAudioSession.sharedInstance().setActive(false)
        }
        if let url = renderedVoiceMessageURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func setRecordButtonIdle() {
        recordButton.configuration?.image = UIImage(systemName: "mic.fill")
        recordButton.configuration?.title = "FeedPost.RecordVoice".localized
        recordButton.configuration?.baseBackgroundColor = Color.primaryMuted
        recordButton.configuration?.baseForegroundColor = Color.primary
    }

    func setRecordButtonRecording(elapsed: TimeInterval) {
        recordButton.configuration?.image = UIImage(systemName: "stop.fill")
        recordButton.configuration?.title = Self.formattedTime(elapsed)
        recordButton.configuration?.baseBackgroundColor = Color.accentRed.withAlphaComponent(0.12)
        recordButton.configuration?.baseForegroundColor = Color.accentRed
    }

    static func formattedTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds.rounded())
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
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

        recordButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        voicePreviewStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        voicePlayerView.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        removeVoiceButton.snp.makeConstraints {
            $0.size.equalTo(28)
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

// MARK: - Constants

private extension FeedPostViewController {
    enum Constants {
        /// A recording shorter than this (an accidental tap) is discarded rather than attached
        static let minimumRecordingDuration: TimeInterval = 1
    }
}
