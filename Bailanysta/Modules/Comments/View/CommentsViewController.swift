//
//  CommentsViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class CommentsViewController: UIViewController {

    private let presenter: CommentsPresenter
    private let collectionView: UICollectionView
    private lazy var dataSource = CommentsDataSource(collectionView: collectionView)

    private let composeView = CommentsComposeView()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.setText("Comments.Empty".localized, size: 15, weight: .regular, textColor: Color.labelSecondary)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private var composeBottomConstraint: Constraint?

    // MARK: - Init

    init(presenter: CommentsPresenter) {
        self.presenter = presenter

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CommentsLayout.make())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        self.collectionView = collectionView

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
        setupNavigationBarTitle("Comments.Title".localized)
        setupUI()
        setupConstraints()
        setupKeyboardObservers()

        presenter.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        let animationOptions = UIView.AnimationOptions(rawValue: curveRawValue << 16)

        let keyboardFrameInView = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY - view.safeAreaInsets.bottom)

        composeBottomConstraint?.update(offset: -(12 + overlap))

        UIView.animate(withDuration: duration, delay: 0, options: animationOptions) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - CommentsViewInput

extension CommentsViewController: CommentsViewInput {
    func display(_ viewData: CommentsViewData) {
        dataSource.reload(comments: viewData.comments)
        emptyStateLabel.isHidden = !viewData.isEmpty
    }

    func setComposerEnabled(_ isEnabled: Bool) {
        composeView.setEnabled(isEnabled)
    }

    func clearComposerInput() {
        composeView.clearInput()
    }
}

// MARK: - Private

private extension CommentsViewController {

    func setupUI() {
        [collectionView, emptyStateLabel, composeView].forEach { view.addSubview($0) }

        composeView.onSendTapped = { [weak self] text in
            self?.presenter.submitComment(text: text)
        }
    }

    func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(composeView.snp.top).offset(-12)
        }
        emptyStateLabel.snp.makeConstraints {
            $0.center.equalTo(collectionView)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        composeView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            composeBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12).constraint
        }
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}
