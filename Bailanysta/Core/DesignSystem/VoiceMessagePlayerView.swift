//
//  VoiceMessagePlayerView.swift
//  Bailanysta
//

import UIKit
import SnapKit
import AVFoundation

/// A compact play/pause + scrub bar for a voice message, backed by `AVPlayer` — reused by the
/// Feed's post cells (remote Storage URL) and the FeedPost composer's recording preview (local
/// file URL); both are just `URL`s to `AVPlayer`.
final class VoiceMessagePlayerView: UIView {

    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var duration: TimeInterval = 0
    private var isScrubbing = false

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 16
        return view
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Color.primary
        return button
    }()

    private let slider: UISlider = {
        let slider = UISlider()
        slider.tintColor = Color.primary
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        return slider
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        updatePlayButtonIcon(isPlaying: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    deinit {
        removeTimeObserver()
    }

    // MARK: - Public

    func configure(url: URL, duration: TimeInterval) {
        stopPlayback()
        // A cell can be reconfigured with a new voice message while still holding an old
        // `AVPlayer`'s observers — both must be torn down before the new player replaces it.
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        self.duration = duration
        slider.value = 0
        timeLabel.setText(Self.formattedTime(duration), size: 13, weight: .medium, textColor: Color.labelSecondary)

        let player = AVPlayer(url: url)
        self.player = player
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackFinished),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        addTimeObserver()
    }

    /// Pauses and rewinds to the start — called by the owning cell's `prepareForReuse()` (a
    /// scrolled-away cell must not keep playing into whatever post gets reused into it) and by
    /// `VoiceMessagePlaybackCoordinator` when another player starts.
    func stopPlayback() {
        player?.pause()
        player?.seek(to: .zero)
        slider.value = 0
        updatePlayButtonIcon(isPlaying: false)
    }
}

// MARK: - Private

private extension VoiceMessagePlayerView {
    func setupSubviews() {
        [playButton, slider, timeLabel].forEach { container.addSubview($0) }
        addSubview(container)

        playButton.addAction(UIAction { [weak self] _ in self?.togglePlayback() }, for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    func setupConstraints() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        playButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }
        timeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(40)
        }
        slider.snp.makeConstraints {
            $0.leading.equalTo(playButton.snp.trailing).offset(4)
            $0.trailing.equalTo(timeLabel.snp.leading).offset(-4)
            $0.centerY.equalToSuperview()
        }
    }

    func togglePlayback() {
        guard let player else { return }

        if player.timeControlStatus == .playing {
            player.pause()
            updatePlayButtonIcon(isPlaying: false)
        } else {
            VoiceMessagePlaybackCoordinator.shared.willStartPlaying(self)
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
            updatePlayButtonIcon(isPlaying: true)
        }
    }

    func updatePlayButtonIcon(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    func addTimeObserver() {
        guard let player else { return }

        let interval = CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.handleTimeUpdate(time.seconds)
        }
    }

    func removeTimeObserver() {
        guard let player, let timeObserverToken else { return }
        player.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
    }

    func handleTimeUpdate(_ seconds: Double) {
        guard !isScrubbing, duration > 0, seconds.isFinite else { return }
        slider.value = Float(seconds / duration)
        timeLabel.setText(Self.formattedTime(duration - seconds), size: 13, weight: .medium, textColor: Color.labelSecondary)
    }

    @objc func handlePlaybackFinished() {
        stopPlayback()
    }

    @objc func sliderTouchDown() {
        isScrubbing = true
    }

    @objc func sliderValueChanged() {
        timeLabel.setText(
            Self.formattedTime(duration - Double(slider.value) * duration),
            size: 13,
            weight: .medium,
            textColor: Color.labelSecondary
        )
    }

    @objc func sliderTouchUp() {
        isScrubbing = false
        guard duration > 0 else { return }
        let target = CMTime(seconds: Double(slider.value) * duration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: target)
    }

    static func formattedTime(_ seconds: TimeInterval) -> String {
        let clamped = max(0, seconds)
        let totalSeconds = Int(clamped.rounded())
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
