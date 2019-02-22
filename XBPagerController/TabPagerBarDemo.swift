//
//  TabPagerBarDemo.swift
//  XBPagerController
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
        temTabPagerBar.dataSource = self
        temTabPagerBar.delegate = self
        temTabPagerBar.register(TabPagerBarCell.self, forCellWithReuseIdentifier: TabPagerBarCell.cellIdentifier)
        return temTabPagerBar
    }()
    
    public lazy var pageView: PagerView = {
       let temPageView = PagerView()
       temPageView.dataSource = self
        temPageView.delegate = self
        temPageView.register(PageViewRed.self, forViewWithReuseIdentifier: "PageViewRed")
        temPageView.register(PageViewYellow.self, forViewWithReuseIdentifier: "PageViewYellow")
        return temPageView
    }()
    
    private lazy var oldIndex = 0
    
    private var array: [String] = ["Swift", "Java", "Kotlin", "Ruby", "PHP", "Objective-C", "JavaScript", "Flutter", "React", "Vue", "Angular"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TabPagerBarDemo"
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(tabPagerBar)
        tabPagerBar.translatesAutoresizingMaskIntoConstraints = false
        tabPagerBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        tabPagerBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tabPagerBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tabPagerBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tabPagerBar.reloadData()
        
        self.view.addSubview(pageView)
        pageView.translatesAutoresizingMaskIntoConstraints = false
        pageView.topAnchor.constraint(equalTo: self.tabPagerBar.bottomAnchor, constant: 100).isActive = true
        pageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        pageView.reloadData()
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
        self.pageView.scrollToView(at: index, animate: true)
    }
}


// MARK: - <#PagerViewDataSource#>
extension TabPagerBarDemo: PagerViewDataSource {
    
    func numberOfViewsInPagerView() -> Int {
        return array.count
    }
    
    func pagerView(_ pagerView: PagerView, viewFor index: Int, prefetching: Bool) -> UIView {
        if index % 2 == 1 {
            let view = pagerView.dequeueReusableView(withReuseIdentifier: "PageViewRed", for: index)
            return view
        } else {
            let view = pagerView.dequeueReusableView(withReuseIdentifier: "PageViewYellow", for: index)
            return view
        }
    }
}


// MARK: - <#PagerViewDelegate#>
extension TabPagerBarDemo: PagerViewDelegate {
    
    func pagerView(_ pagerView: PagerView, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool) {
        self.tabPagerBar.scrollToItem(from: fromIndex, to: toIndex, animate: animated)
    }
    
    func pagerView(_ pagerView: PagerView, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        self.tabPagerBar.scrollToItem(from: fromIndex, to: toIndex, progress: progress)
    }
}



final class PageViewRed: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class PageViewYellow: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
