//
//  TabPagerBarDemo.swift
//  XBTabPagerBar
//
//  Created by xiaobin liu on 2019/2/18.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - TabPagerBarDemo
final class TabPagerBarDemo: UIViewController {
    
    /// TabPagerBar
    public lazy var tabPagerBar: TabPagerBar = {
        let temTabPagerBar = TabPagerBar()
//        temTabPagerBar.backgroundColor = UIColor.white
//        temTabPagerBar.layout.barStyle = .cover
//        temTabPagerBar.layout.progressRadius = 4
//        temTabPagerBar.layout.selectedTextColor = UIColor.white
//        temTabPagerBar.progressView.backgroundColor = UIColor.red
        temTabPagerBar.dataSource = self
        temTabPagerBar.delegate = self
        temTabPagerBar.register(TabPagerBarCell.self, forCellWithReuseIdentifier: TabPagerBarCell.cellIdentifier)
        return temTabPagerBar
    }()
    
    private lazy var oldIndex = 0
    
    private var array: [String] = ["Swift", "Java", "Kotlin", "Ruby", "PHP", "Objective-C", "JavaScript", "Flutter", "React", "Vue", "Angular"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TabPagerBarDemo"
        self.view.backgroundColor = UIColor.black
        
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
extension TabPagerBarDemo: TabPagerBarDataSource {
    
    func numberOfItemsInPagerTabBar() -> Int {
        return array.count
    }
    
    func pagerTabBar(_ pagerTabBar: TabPagerBar, cellForItemAt index: Int) -> TabPagerCellProtocol {
        let cell = pagerTabBar.dequeueReusableCell(withReuseIdentifier: TabPagerBarCell.cellIdentifier, for: index)
        cell.titleLabel.text = array[index]
        cell.titleLabel.textColor = UIColor.black
        return cell
    }
}


// MARK: - TabPagerBarDelegate
extension TabPagerBarDemo: TabPagerBarDelegate {
    
    func pagerTabBar(_ pagerTabBar: TabPagerBar, widthForItemAt index: Int) -> CGFloat {
        return pagerTabBar.cellWidth(forTitle: array[index])
    }
    
    func pagerTabBar(_ pagerTabBar: TabPagerBar, didSelectItemAt index: Int) {
        
        self.tabPagerBar.scrollToItem(from: oldIndex, to: index, animate: true)
        self.oldIndex = index
    }
}

