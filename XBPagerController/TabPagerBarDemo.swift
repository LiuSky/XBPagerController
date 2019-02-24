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
    
    public lazy var pageView: PagerController = {
       let temPageView = PagerController()
        temPageView.dataSource = self
        temPageView.delegate = self
        temPageView.register(PageViewRedViewController.self, forControllerWithReuseIdentifier: "PageViewRedViewController")
        temPageView.register(PageViewYellowViewController.self, forControllerWithReuseIdentifier: "PageViewYellowViewController")
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
        tabPagerBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tabPagerBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tabPagerBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tabPagerBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tabPagerBar.reloadData()
        
        self.addChild(pageView)
        self.view.addSubview(pageView.view)
        pageView.view.translatesAutoresizingMaskIntoConstraints = false
        pageView.view.topAnchor.constraint(equalTo: self.tabPagerBar.bottomAnchor).isActive = true
        pageView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pageView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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
        self.pageView.scrollToController(at: index, animate: true)
    }
}


// MARK: - <#PagerViewDataSource#>
extension TabPagerBarDemo: PagerControllerDataSource {
    func numberOfControllersInPagerController() -> Int {
        return array.count
    }
    
    func pagerController(_ pagerController: PagerController, controllerFor index: Int, prefetching: Bool) -> UIViewController {
        if index % 2 == 1 {
            let viewController =
                
                pagerController.dequeueReusableController(withReuseIdentifier: "PageViewRedViewController", for: index)
            return viewController
        } else {
            let viewController =
                
                pagerController.dequeueReusableController(withReuseIdentifier: "PageViewYellowViewController", for: index)
            return viewController
        }
    }
}



// MARK: - <#PagerViewDelegate#>
extension TabPagerBarDemo: PagerControllerDelegate {
    
    func pagerController(_ pagerController: PagerController, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool) {
        self.tabPagerBar.scrollToItem(from: fromIndex, to: toIndex, animate: animated)
    }
    
    func pagerController(_ pagerController: PagerController, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat) {
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

final class PageViewRedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
    }
}

final class PageViewYellowViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellow
    }
}
