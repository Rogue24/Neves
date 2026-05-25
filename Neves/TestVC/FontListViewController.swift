//
//  FontListViewController.swift
//  Neves
//
//  Created by aa on 2026/5/25.
//

import UIKit
import FunnyButton
import SnapKit

class FontListViewController: TestBaseViewController, UITableViewDataSource, UITableViewDelegate {

    struct FontItem {
        let familyName: String
        let fontName: String
    }

    private var fonts: [FontItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "iOS Fonts"

        fonts = UIFont.familyNames
            .sorted()
            .flatMap { familyName in
                UIFont.fontNames(forFamilyName: familyName)
                    .sorted()
                    .map { fontName in
                        FontItem(familyName: familyName, fontName: fontName)
                    }
            }

        let tableView = UITableView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(FontCell.self, forCellReuseIdentifier: "FontCell")
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeFunnyActions()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fonts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FontCell",
            for: indexPath
        ) as! FontCell

        cell.configure(with: fonts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private class FontCell: UITableViewCell {

    private let sampleLabel = UILabel()
    private let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sampleLabel.text = "Hello 你好 123 ABC abc"
        sampleLabel.font = UIFont.systemFont(ofSize: 18)
        sampleLabel.numberOfLines = 1

        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .secondaryLabel
        nameLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [sampleLabel, nameLabel])
        stack.axis = .vertical
        stack.spacing = 4

        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
        let lpGR = UILongPressGestureRecognizer(target: self, action: #selector(copyStr))
        lpGR.minimumPressDuration = 0.5
        contentView.addGestureRecognizer(lpGR)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func configure(with item: FontListViewController.FontItem) {
        sampleLabel.font = UIFont(name: item.fontName, size: 18)
        nameLabel.text = "\(item.familyName)\n\(item.fontName)"
    }
    
    @objc private func copyStr() {
        UIPasteboard.general.string = nameLabel.text
        JPHUD.showInfo(withStatus: "已复制字体名到剪贴板")
    }
}
