//
//  ViewController.swift
//  XBTabPagerBar
//
//  Created by xiaobin liu on 2019/2/14.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - 演示控制器
final class ViewController: UIViewController {

    /// TabPagerBar
    private lazy var tabPagerBar: TabPagerBar = {
        let temTabPagerBar = TabPagerBar()
        temTabPagerBar.backgroundColor = UIColor.gray
        temTabPagerBar.layout.barStyle = .cover
        temTabPagerBar.layout.progressRadius = 4
        temTabPagerBar.progressView.backgroundColor = UIColor.lightGray
        temTabPagerBar.dataSource = self
        temTabPagerBar.delegate = self
        temTabPagerBar.register(TabPagerBarCell.self, forCellWithReuseIdentifier: TabPagerBarCell.cellIdentifier)
        return temTabPagerBar
    }()
    
    private lazy var oldIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "演示Demo"
        self.view.addSubview(tabPagerBar)
        
        tabPagerBar.translatesAutoresizingMaskIntoConstraints = false
        tabPagerBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100)
            .isActive = true
        tabPagerBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tabPagerBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tabPagerBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tabPagerBar.reloadData()
    }
}


// MARK: - TabPagerBarDataSource
extension ViewController: TabPagerBarDataSource {
    
    func numberOfItemsInPagerTabBar() -> Int {
        return 15
    }
    
    func pagerTabBar(_ pagerTabBar: TabPagerBar, cellForItemAt index: Int) -> CellProtocol {
        let cell = pagerTabBar.dequeueReusableCell(withReuseIdentifier: TabPagerBarCell.cellIdentifier, for: index)
        cell.titleLabel.text = "\(index)111"
        cell.titleLabel.textColor = UIColor.black
        return cell
    }
}


// MARK: - TabPagerBarDelegate
extension ViewController: TabPagerBarDelegate {
    
    func pagerTabBar(_ pagerTabBar: TabPagerBar, widthForItemAt index: Int) -> CGFloat {
        return 44
    }
    
    func pagerTabBar(_ pagerTabBar: TabPagerBar, didSelectItemAt index: Int) {
        
        self.tabPagerBar.scrollToItem(from: oldIndex, to: index, animate: true)
        self.oldIndex = index
    }
}

