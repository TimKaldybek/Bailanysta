//
//  VoiceMessagePlaybackCoordinator.swift
//  Bailanysta
//

/// Ensures only one `VoiceMessagePlayerView` plays at a time — starting a new one stops whichever
/// was playing, so scrolling the feed never leaves two voice messages talking over each other.
final class VoiceMessagePlaybackCoordinator {
    static let shared = VoiceMessagePlaybackCoordinator()

    private weak var current: VoiceMessagePlayerView?

    private init() {}

    func willStartPlaying(_ view: VoiceMessagePlayerView) {
        if let current, current !== view {
            current.stopPlayback()
        }
        current = view
    }
}
