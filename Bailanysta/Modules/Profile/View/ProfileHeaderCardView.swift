//
//  ProfileHeaderCardView.swift
//  Bailanysta
//

import UIKit
import SnapKit
import Kingfisher

/// Карточка профиля: аватар, имя, био, кнопки действий, статистика и таб-бар (Posts/Replies/Likes)
final class ProfileHeaderCardView: UIView {

    var onEditProfileTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
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
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel = UILabel()
    private let handleRoleLabel = UILabel()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Profile.ChangePhoto".localized, for: .normal)
        button.setTitleColor(Color.onPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = Color.primary
        button.layer.cornerRadius = 20
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Profile.Share".localized, for: .normal)
        button.setTitleColor(Color.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = Color.background
        button.layer.cornerRadius = 20
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [editProfileButton, shareButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 12
        return stack
    }()

    private let postsStatView = ProfileHeaderCardView.makeStatView(captionKey: "Profile.Stat.Posts")
    private let followersStatView = ProfileHeaderCardView.makeStatView(captionKey: "Profile.Stat.Followers")
    private let followingStatView = ProfileHeaderCardView.makeStatView(captionKey: "Profile.Stat.Following")

    private lazy var statsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postsStatView, followersStatView, followingStatView])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.divider
        return view
    }()

    private let postsTabButton = ProfileHeaderCardView.makeTabButton(title: ProfileTab.posts.title)
    private let repliesTabButton = ProfileHeaderCardView.makeTabButton(title: ProfileTab.replies.title)
    private let likesTabButton = ProfileHeaderCardView.makeTabButton(title: ProfileTab.likes.title)

    private lazy var tabButtons: [ProfileTab: UIButton] = [
        .posts: postsTabButton,
        .replies: repliesTabButton,
        .likes: likesTabButton
    ]

    private lazy var tabsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postsTabButton, repliesTabButton, likesTabButton])
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

    func configure(with viewData: ProfileHeaderViewData, selectedTab: ProfileTab) {
        if let avatarURL = viewData.avatarURL {
            avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(systemName: viewData.avatarImageName))
        } else {
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = UIImage(systemName: viewData.avatarImageName)
        }
        nameLabel.setText(viewData.name, size: 22, weight: .bold, textColor: Color.label)
        handleRoleLabel.setText(viewData.handleAndRole, size: 14, weight: .regular, textColor: Color.labelSecondary)
        bioLabel.setText(viewData.bio, size: 15, weight: .regular, textColor: Color.labelSecondary)

        postsStatView.valueLabel.setText(viewData.postsCountText, size: 18, weight: .bold, textColor: Color.label)
        followersStatView.valueLabel.setText(viewData.followersCountText, size: 18, weight: .bold, textColor: Color.label)
        followingStatView.valueLabel.setText(viewData.followingCountText, size: 18, weight: .bold, textColor: Color.label)

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

private extension ProfileHeaderCardView {
    func setupUI() {
        backgroundColor = Color.surface
        layer.cornerRadius = 24
        layer.shadowColor = Color.shadow.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)

        avatarContainer.addSubview(avatarImageView)

        [
            avatarContainer, nameLabel, handleRoleLabel, bioLabel, buttonsStack,
            statsStack, divider, tabsStack, tabIndicatorView
        ].forEach { addSubview($0) }

        editProfileButton.addAction(UIAction { [weak self] _ in
            self?.onEditProfileTapped?()
        }, for: .touchUpInside)

        shareButton.addAction(UIAction { [weak self] _ in
            self?.onShareTapped?()
        }, for: .touchUpInside)

        ProfileTab.allCases.forEach { tab in
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
            $0.size.equalTo(60)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        handleRoleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        bioLabel.snp.makeConstraints {
            $0.top.equalTo(handleRoleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        buttonsStack.snp.makeConstraints {
            $0.top.equalTo(bioLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
        editProfileButton.snp.makeConstraints {
            $0.width.equalTo(140)
        }
        shareButton.snp.makeConstraints {
            $0.width.equalTo(90)
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
        ProfileTab.allCases.forEach { tab in
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

    static func makeStatView(captionKey: String) -> ProfileStatView {
        let view = ProfileStatView()
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
private final class ProfileStatView: UIView {
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
