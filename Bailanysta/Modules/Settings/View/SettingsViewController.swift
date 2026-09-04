//
//  SettingsViewController.swift
//  Bailanysta
//
//

import UIKit
import SnapKit

final class SettingsViewController: UIViewController {
    var completionHandler: ((SettingType) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SettingCell.self)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    private let presenter: SettingsPresenter
    
    init(presenter: SettingsPresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
        
        setupUI()
        setupNavigationBarTitle("Settings".localized)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = Color.background
        
        tableView.layer.cornerRadius = 12
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview()
        }
    }

    func reloadSettings() {
        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completionHandler?(presenter.model[indexPath.row].type)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingCell = tableView.dequeueCell(for: indexPath)
        cell.configure(model: presenter.model[indexPath.row], shouldShowSeparator: indexPath.row != 0)
        
        return cell
    }
}
