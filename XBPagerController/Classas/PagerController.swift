//
//  PagerController.swift
//  XBPagerController
//
//  Created by xiaobin liu on 2019/2/23.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - 数据源
public protocol PagerControllerDataSource: NSObjectProtocol {
    
    func numberOfControllersInPagerController() -> Int
    func pagerController(_ pagerController: PagerController, controllerFor index: Int, prefetching: Bool) -> UIViewController
}


/// MARK - 回调
public protocol PagerControllerDelegate: NSObjectProtocol {
    
    func pagerController(_ pagerController: PagerController, viewWillAppear viewController: UIViewController, for index: Int)
    func pagerController(_ pagerController: PagerController, viewDidAppear viewController: UIViewController, for index: Int)
    func pagerController(_ pagerController: PagerController, viewWillDisappear viewController: UIViewController, for index: Int)
    func pagerController(_ pagerController: PagerController, viewDidDisappear viewController: UIViewController, for index: Int)
    func pagerController(_ pagerController: PagerController, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool)
    func pagerController(_ pagerController: PagerController, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat)
    func pagerControllerDidScroll(_ pagerController: PagerController)
    func pagerControllerWillBeginScrolling(_ pagerController: PagerController, animate: Bool)
    func pagerControllerDidEndScrolling(_ pagerController: PagerController, animate: Bool)
}

extension PagerControllerDelegate {
    
    func pagerController(_ pagerController: PagerController, viewWillAppear viewController: UIViewController, for index: Int) {}
    func pagerController(_ pagerController: PagerController, viewDidAppear viewController: UIViewController, for index: Int) {}
    func pagerController(_ pagerController: PagerController, viewWillDisappear viewController: UIViewController, for index: Int) {}
    func pagerController(_ pagerController: PagerController, viewDidDisappear viewController: UIViewController, for index: Int) {}
    func pagerController(_ pagerController: PagerController, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool) {}
    func pagerController(_ pagerController: PagerController, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat) {}
    func pagerControllerDidScroll(_ pagerController: PagerController) {}
    func pagerControllerWillBeginScrolling(_ pagerController: PagerController, animate: Bool) {}
    func pagerControllerDidEndScrolling(_ pagerController: PagerController, animate: Bool) {}
}



/// MARK - PagerController
public class PagerController: UIViewController {
    
    /// 目前暂时这样子弄
    public weak var dataSource: PagerControllerDataSource!
    
    /// 协议
    public weak var delegate: PagerControllerDelegate?
    
    /// 布局
    private(set) lazy var layout: PagerViewLayout = {
       
        let scrollView = UIScrollView()
        let temLayout = PagerViewLayout(scrollView)
        temLayout.dataSource = self
        temLayout.delegate = self
        temLayout.adjustScrollViewInset = true
        return temLayout
    }()
    
    /// 滚动视图
    public var scrollView: UIScrollView {
        return self.layout.scrollView
    }
    
    /// 视图总数
    public var countOfControllers: Int {
        return self.layout.countOfPagerItems
    }
    
    /// 当前索引
    public var curIndex: Int {
        return self.layout.curIndex
    }
    
    /// 显示视图数组
    public var visibleViews: [UIViewController] {
        return self.layout.visibleItems as? [UIViewController] ?? []
    }
    
    /// 默认的是的。如果是，系统自动调用视图外观方法(例如: viewWillAppear等)
    public var automaticallySystemManagerViewAppearanceMethods: Bool = true
    
    /// 内容间距
    public var contentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.automaticallySystemManagerViewAppearanceMethods = true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.addFixAutoAdjustInsetScrollView()
        self.view.addSubview(self.layout.scrollView)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.layout.scrollView.frame = self.view.bounds.inset(by: contentInset)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layout.scrollView.frame = self.view.bounds.inset(by: contentInset)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 防止系统automaticallyAdjustsScrollViewInsets
    private func addFixAutoAdjustInsetScrollView() {
        let view = UIView()
        self.view.addSubview(view)
    }
    
    //该方法返回NO则childViewController不会自动viewWillAppear和viewWillDisappear对应的方法
    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return self.automaticallySystemManagerViewAppearanceMethods
    }
    
    deinit {
        debugPrint("释放PageViewController")
    }
}


// MARK: - public method
extension PagerController {
    
    public func controller(for index: Int) -> UIViewController? {
        return self.layout.item(for: index) as? UIViewController
    }
    
    public func scrollToController(at index: Int, animate: Bool) {
        self.layout.scrollToItem(at: index, animate: animate)
    }
    
    public func updateData() {
        self.layout.updateData()
    }
    
    public func reloadData() {
        self.layout.reloadData()
    }
    
    public func register(_ Class: AnyClass, forControllerWithReuseIdentifier identifier: String) {
        self.layout.register(Class, forItemWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableController(withReuseIdentifier identifier: String, for index: Int) -> UIViewController {
        return self.layout.dequeueReusableItem(withReuseIdentifier: identifier, for: index) as! UIViewController
    }
}

// MARK: - private method
extension PagerController {
    
    private func childViewController(_ childViewController: UIViewController?, beginAppearanceTransition isAppearing: Bool, animated: Bool) {
        if !automaticallySystemManagerViewAppearanceMethods {
            childViewController?.beginAppearanceTransition(isAppearing, animated: animated)
        }
    }
    
    private func childViewControllerEndAppearanceTransition(_ childViewController: UIViewController?) {
        if !automaticallySystemManagerViewAppearanceMethods {
            childViewController?.endAppearanceTransition()
        }
    }
    
    private func willBeginScrollingAnimate(_ animate: Bool) {
        self.delegate?.pagerControllerWillBeginScrolling(self, animate: animate)
    }
    
    private func didEndScrollingAnimate(_ animate: Bool) {
        self.delegate?.pagerControllerDidEndScrolling(self, animate: animate)
    }
}



// MARK: - PagerViewLayoutDataSource
extension PagerController: PagerViewLayoutDataSource {
    
    public func numberOfItemsInPagerViewLayout() -> Int {
        return self.dataSource.numberOfControllersInPagerController()
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, itemFor index: Int, prefetching: Bool) -> AnyObject {
        return self.dataSource.pagerController(self, controllerFor: index, prefetching: prefetching)
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, viewForItem item: AnyObject, at index: Int) -> UIView {
        let viewController = item as! UIViewController
        return viewController.view
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, viewControllerForItem item: AnyObject, at index: Int) -> UIViewController {
        return item as! UIViewController
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, addVisibleItem item: AnyObject, at index: Int) {
        
        let viewController = item as! UIViewController
        self.delegate?.pagerController(self, viewWillAppear: viewController, for: index)
        // addChildViewController
        self.addChild(viewController)
        self.childViewController(viewController, beginAppearanceTransition: true, animated: true)
        pagerViewLayout.scrollView.addSubview(viewController.view)
        self.childViewControllerEndAppearanceTransition(viewController)
        viewController.didMove(toParent: self)
        self.delegate?.pagerController(self, viewDidAppear: viewController, for: index)
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, removeInVisibleItem item: AnyObject, at index: Int) {
        
        let viewController = item as! UIViewController
        self.delegate?.pagerController(self, viewWillDisappear: viewController, for: index)
        
        // removeChildViewController
        viewController.willMove(toParent: nil)
        self.childViewController(viewController, beginAppearanceTransition: false, animated: true)
        viewController.view.removeFromSuperview()
        self.childViewControllerEndAppearanceTransition(viewController)
        viewController.removeFromParent()
        self.delegate?.pagerController(self, viewDidDisappear: viewController, for: index)
    }
}


// MARK: - PagerViewLayoutDelegate
extension PagerController: PagerViewLayoutDelegate {
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool) {
        self.delegate?.pagerController(self, transitionFrom: fromIndex, to: toIndex, animated: animated)
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        self.delegate?.pagerController(self, transitionFrom: fromIndex, to: toIndex, progress: progress)
    }
    
    public func pagerViewLayoutDidScroll(_ pagerViewLayout: PagerViewLayout) {
        self.delegate?.pagerControllerDidScroll(self)
    }
    
    public func pagerViewLayoutWillBeginDragging(_ pagerViewLayout: PagerViewLayout) {
        self.willBeginScrollingAnimate(true)
    }
    
    public func pagerViewLayoutWillBeginScroll(toView pagerViewLayout: PagerViewLayout, animate: Bool) {
        self.willBeginScrollingAnimate(animate)
    }
    
    public func pagerViewLayoutDidEndDecelerating(_ pagerViewLayout: PagerViewLayout) {
        self.willBeginScrollingAnimate(true)
    }
    
    public func pagerViewLayoutDidEndScroll(toView pagerViewLayout: PagerViewLayout, animate: Bool) {
        self.didEndScrollingAnimate(animate)
    }
    
    public func pagerViewLayoutDidEndScrollingAnimation(_ pagerViewLayout: PagerViewLayout) {
        self.didEndScrollingAnimate(true)
    }
}

