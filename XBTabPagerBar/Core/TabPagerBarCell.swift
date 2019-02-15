//
//  TabPagerBarCell.swift
//  XBTabPagerBar
//
//  Created by xiaobin liu on 2019/2/14.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


public typealias TabPagerCellProtocol = UICollectionViewCell & TabPagerBarTabPagerCellProtocol


/// MARK - TabPagerBarTabPagerCellProtocol
@objc public protocol TabPagerBarTabPagerCellProtocol: NSObjectProtocol {
    
    var titleLabel: UILabel { get }
}


/// MARK - TabPagerBarCell
public class TabPagerBarCell: TabPagerCellProtocol {
    
    /// 唯一标示
    public static var cellIdentifier = "XBTabPagerBarCell"
    
    public var titleLabel: UILabel {
        return self.privateLabel
    }
    
    /// 标签
    private lazy var privateLabel: UILabel = {
        let temLabel = UILabel()
        temLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        temLabel.textColor = UIColor.darkText
        temLabel.textAlignment = .center
        return temLabel
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configView()
    }
    
    /// 配置View
    private func configView() {
        self.contentView.addSubview(privateLabel)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.privateLabel.frame = self.bounds
    }
}
