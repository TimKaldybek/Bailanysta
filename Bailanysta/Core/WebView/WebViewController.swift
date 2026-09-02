//
//  WebViewController.swift
//  Bailanysta
//

import UIKit
import WebKit

final class WebViewController: UIViewController {

    // MARK: - UI

    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = Color.background
        return v
    }()

    private let hostLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Color.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let icon = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(icon, for: .normal)
        button.tintColor = Color.primary
        button.backgroundColor = Color.primary.withAlphaComponent(0.12)
        button.layer.cornerRadius = 18
        return button
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = Color.stroke.withAlphaComponent(0.5)
        return v
    }()

    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.progressTintColor = Color.primary
        pv.trackTintColor = .clear
        pv.alpha = 0
        return pv
    }()

    private let webView = WKWebView()

    // MARK: - State

    private var progressObservation: NSKeyValueObservation?
    private let url: URL

    // MARK: - Init

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupConstraints()
        setupActions()
        observeProgress()
        loadWebViewContent()
    }

    deinit {
        progressObservation?.invalidate()
    }
}

// MARK: - Setup UI

private extension WebViewController {

    func setupView() {
        view.backgroundColor = Color.background
        hostLabel.text = url.host ?? url.absoluteString
    }

    func setupSubviews() {
        headerView.addSubview(hostLabel)
        headerView.addSubview(closeButton)
        [headerView, separator, progressView, webView].forEach(view.addSubview)
    }

    func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }

        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(36)
        }

        hostLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(68)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }

        separator.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }

        webView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    @objc func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: - Progress

private extension WebViewController {

    func observeProgress() {
        progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard let self, let value = change.newValue else { return }
            let progress = Float(value)

            UIView.animate(withDuration: 0.2) {
                self.progressView.alpha = progress < 1.0 ? 1 : 0
            }
            self.progressView.setProgress(progress, animated: true)
        }
    }

    func loadWebViewContent() {
        webView.load(URLRequest(url: url))
    }
}
