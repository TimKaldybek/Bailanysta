//
//  OtherProfileHeaderCardView.swift
//  Bailanysta
//

import UIKit
import SnapKit
import Kingfisher

/// Карточка чужого профиля: аватар, имя, тэглайн, Follow/Message, статистика и таб-бар (Posts/Likes/Replies)
final class OtherProfileHeaderCardView: UIView {

    var onFollowTapped: (() -> Void)?
    var onMessageTapped: (() -> Void)?
    var onTabSelected: ((ProfileTab) -> Void)?

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 40
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel = UILabel()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.layer.cornerRadius = 20
        return button
    }()

    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Profile.Message".localized, for: .normal)
        button.setTitleColor(Color.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = Color.background
        button.layer.cornerRadius = 20
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [followButton, messageButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 12
        return stack
    }()

    private let followersStatView = OtherProfileHeaderCardView.makeStatView(captionKey: "Profile.Stat.Followers")
    private let followingStatView = OtherProfileHeaderCardView.makeStatView(captionKey: "Profile.Stat.Following")
    private let postsStatView = OtherProfileHeaderCardView.makeStatView(captionKey: "Profile.Stat.Posts")

    private lazy var statsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [followersStatView, followingStatView, postsStatView])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.divider
        return view
    }()

    private let postsTabButton = OtherProfileHeaderCardView.makeTabButton(title: ProfileTab.posts.title)
    private let likesTabButton = OtherProfileHeaderCardView.makeTabButton(title: ProfileTab.likes.title)
    private let repliesTabButton = OtherProfileHeaderCardView.makeTabButton(title: ProfileTab.replies.title)

    private lazy var tabButtons: [ProfileTab: UIButton] = [
        .posts: postsTabButton,
        .likes: likesTabButton,
        .replies: repliesTabButton
    ]

    /// Порядок вкладок в этом экране — Posts / Likes / Replies (отличается от собственного профиля)
    private let tabOrder: [ProfileTab] = [.posts, .likes, .replies]

    private lazy var tabsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postsTabButton, likesTabButton, repliesTabButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let tabIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primary
        view.layer.cornerRadius = 1.5
        return view
    }()

    private var selectedTab: ProfileTab = .posts

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Public

    func configure(with viewData: OtherProfileHeaderViewData, selectedTab: ProfileTab) {
        if let avatarURL = viewData.avatarURL {
            avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(systemName: viewData.avatarImageName))
        } else {
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = UIImage(systemName: viewData.avatarImageName)
        }
        nameLabel.setText(viewData.name, size: 22, weight: .bold, textColor: Color.label)
        taglineLabel.setText(viewData.tagline, size: 15, weight: .regular, textColor: Color.labelSecondary)

        followersStatView.valueLabel.setText(viewData.followersCountText, size: 18, weight: .bold, textColor: Color.label)
        followingStatView.valueLabel.setText(viewData.followingCountText, size: 18, weight: .bold, textColor: Color.label)
        postsStatView.valueLabel.setText(viewData.postsCountText, size: 18, weight: .bold, textColor: Color.label)

        followButton.setTitle(viewData.followButtonTitle, for: .normal)
        followButton.backgroundColor = viewData.isFollowing ? Color.primaryMuted : Color.primary
        followButton.setTitleColor(viewData.isFollowing ? Color.primary : Color.onPrimary, for: .normal)

        self.selectedTab = selectedTab
        updateTabAppearance(animated: false)
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicatorPosition(animated: false)
    }
}

// MARK: - Private

private extension OtherProfileHeaderCardView {
    func setupUI() {
        backgroundColor = Color.surface
        layer.cornerRadius = 24
        layer.shadowColor = Color.shadow.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)

        avatarContainer.addSubview(avatarImageView)

        [
            avatarContainer, nameLabel, taglineLabel, buttonsStack,
            statsStack, divider, tabsStack, tabIndicatorView
        ].forEach { addSubview($0) }

        followButton.addAction(UIAction { [weak self] _ in
            self?.onFollowTapped?()
        }, for: .touchUpInside)

        messageButton.addAction(UIAction { [weak self] _ in
            self?.onMessageTapped?()
        }, for: .touchUpInside)

        tabOrder.forEach { tab in
            guard let button = tabButtons[tab] else { return }
            button.addAction(UIAction { [weak self] _ in
                self?.handleTabTapped(tab)
            }, for: .touchUpInside)
        }
    }

    func setupConstraints() {
        avatarContainer.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        avatarImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        taglineLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        buttonsStack.snp.makeConstraints {
            $0.top.equalTo(taglineLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
        followButton.snp.makeConstraints {
            $0.width.equalTo(140)
        }
        messageButton.snp.makeConstraints {
            $0.width.equalTo(110)
        }
        statsStack.snp.makeConstraints {
            $0.top.equalTo(buttonsStack.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        divider.snp.makeConstraints {
            $0.top.equalTo(statsStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        tabsStack.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
        tabIndicatorView.snp.makeConstraints {
            $0.bottom.equalTo(tabsStack.snp.bottom)
            $0.height.equalTo(3)
            $0.leading.equalTo(postsTabButton)
            $0.width.equalTo(postsTabButton)
        }
    }

    func handleTabTapped(_ tab: ProfileTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        updateTabAppearance(animated: true)
        onTabSelected?(tab)
    }

    func updateTabAppearance(animated: Bool) {
        tabOrder.forEach { tab in
            let isSelected = tab == selectedTab
            let button = tabButtons[tab]
            button?.setTitleColor(isSelected ? Color.primary : Color.labelSecondary, for: .normal)
            button?.titleLabel?.font = .systemFont(ofSize: 15, weight: isSelected ? .bold : .regular)
        }
        updateIndicatorPosition(animated: animated)
    }

    func updateIndicatorPosition(animated: Bool) {
        guard let selectedButton = tabButtons[selectedTab] else { return }

        tabIndicatorView.snp.remakeConstraints {
            $0.bottom.equalTo(tabsStack.snp.bottom)
            $0.height.equalTo(3)
            $0.leading.equalTo(selectedButton)
            $0.width.equalTo(selectedButton)
        }

        guard animated else {
            layoutIfNeeded()
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    static func makeStatView(captionKey: String) -> OtherProfileStatView {
        let view = OtherProfileStatView()
        view.captionLabel.setText(captionKey.localized.uppercased(), size: 11, weight: .semibold, textColor: Color.labelSecondary)
        return view
    }

    static func makeTabButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(Color.labelSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        return button
    }
}

/// Колонка статистики: значение сверху, подпись снизу
private final class OtherProfileStatView: UIView {
    let valueLabel = UILabel()
    let captionLabel = UILabel()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        valueLabel.textAlignment = .center
        captionLabel.textAlignment = .center
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
