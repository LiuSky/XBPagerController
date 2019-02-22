//
//  PagerView.swift
//  XBPagerController
//
//  Created by xiaobin liu on 2019/2/22.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - 数据源协议
public protocol PagerViewDataSource: NSObjectProtocol {
    
    /// 数据源项
    ///
    /// - Returns: <#return value description#>
    func numberOfViewsInPagerView() -> Int
    
    
    /// 获取索引项View
    ///
    /// - Parameters:
    ///   - pagerView: pagerView
    ///   - index: index
    ///   - prefetching: prefetching
    /// - Returns: UIView
    func pagerView(_ pagerView: PagerView, viewFor index: Int, prefetching: Bool) -> UIView
}


/// MARK - 委托协议
public protocol PagerViewDelegate: NSObjectProtocol {
    
    
    /// 视图将要显示方法
    ///
    /// - Parameters:
    ///   - pagerView: pagerView
    ///   - view: view
    ///   - index: index
    func pagerView(_ pagerView: PagerView, willAppear view: UIView, for index: Int)
    
    
    
    /// 视图已经显示方法
    ///
    /// - Parameters:
    ///   - pagerView: pagerView
    ///   - view: view
    ///   - index: index
    func pagerView(_ pagerView: PagerView, didAppear view: UIView, for index: Int)
    
    
    
    /// 视图将要隐藏方法
    ///
    /// - Parameters:
    ///   - pagerView: pagerView
    ///   - view: view
    ///   - index: index
    func pagerView(_ pagerView: PagerView, willDisappear view: UIView, for index: Int)
    
    
    
    /// 视图已经隐藏方法
    ///
    /// - Parameters:
    ///   - pagerView: pagerView
    ///   - view: view
    ///   - index: index
    func pagerView(_ pagerView: PagerView, didDisappear view: UIView, for index: Int)
    
    
    
    /// 过渡动画方法
    ///
    /// - Parameters:
    ///   - pagerView: pagerView
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - animated: animated
    func pagerView(_ pagerView: PagerView, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool)
    
    
    
    /// 过渡动画进度
    ///
    /// - Parameters:
    ///   - pagerView: pagerView
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - progress: progress
    func pagerView(_ pagerView: PagerView, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat)
    
    
    
    /// 开始滚动方法
    ///
    /// - Parameter pageView: <#pageView description#>
    func pagerViewDidScroll(_ pageView: PagerView)
    
    
    /// 将要开始滚动方法
    ///
    /// - Parameters:
    ///   - pageView: pageView
    ///   - animate: animate
    func pagerViewWillBeginScrolling(_ pageView: PagerView, animate: Bool)
    
    
    /// 完成滚动方法
    ///
    /// - Parameters:
    ///   - pageView: pageView
    ///   - animate: animate
    func pagerViewDidEndScrolling(_ pageView: PagerView, animate: Bool)
}


// MARK: - 协议扩展解决(可选问题不想要用@objc)
extension PagerViewDelegate {
    
    func pagerView(_ pagerView: PagerView, willAppear view: UIView, for index: Int) {}
    func pagerView(_ pagerView: PagerView, didAppear view: UIView, for index: Int) {}
    func pagerView(_ pagerView: PagerView, willDisappear view: UIView, for index: Int) {}
    func pagerView(_ pagerView: PagerView, didDisappear view: UIView, for index: Int) {}
    func pagerView(_ pagerView: PagerView, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool) {}
    func pagerView(_ pagerView: PagerView, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat) {}
    func pagerViewDidScroll(_ pageView: PagerView) {}
    func pagerViewWillBeginScrolling(_ pageView: PagerView, animate: Bool) {}
    func pagerViewDidEndScrolling(_ pageView: PagerView, animate: Bool) {}
}



/// MARK - PagerView
public class PagerView: UIView {
    
    /// 必须实现
    public weak var dataSource: PagerViewDataSource!
    
    /// 委托
    public weak var delegate: PagerViewDelegate?
    
    /// 布局
    private(set) var layout: PagerViewLayout?
    
    /// 滚动视图
    private(set) var scrollView: UIScrollView?
    
    /// 视图总数
    public var countOfPagerViews: Int {
        return self.layout?.countOfPagerItems ?? 0
    }
    
    /// 当前索引
    public var curIndex: Int {
        return self.layout?.curIndex ?? -1
    }
    
    /// 显示视图数组
    public var visibleViews: [UIView] {
        return self.layout?.visibleItems as? [UIView] ?? []
    }
    
    /// 内容间距
    public var contentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addFixAutoAdjustInsetScrollView()
        self.addLayoutScrollView()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        self.addFixAutoAdjustInsetScrollView()
        self.addLayoutScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 防止系统automaticallyAdjustsScrollViewInsets
    private func addFixAutoAdjustInsetScrollView() {
        
        let view = UIView()
        addSubview(view)
    }
    
    /// 添加滚动View
    private func addLayoutScrollView() {
        let contentView = UIScrollView()
        let layout = PagerViewLayout(contentView)
        layout.dataSource = self
        layout.delegate = self
        self.addSubview(contentView)
        self.layout = layout
        self.scrollView = contentView
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layout?.scrollView.frame = self.bounds.inset(by: contentInset)
    }
    
    deinit {
        debugPrint("释放PageView")
    }
}



// MARK: - private
extension PagerView {
    
    func willBeginScrollingAnimate(_ animate: Bool) {
        
    }
    
    func didEndScrollingAnimate(_ animate: Bool) {
    }
}


// MARK: - public
extension PagerView {
    
    
    /// 根据索引获取缓存View
    ///
    /// - Parameter index: 索引
    /// - Returns: UIView?
    public func view(for index: Int) -> UIView? {
        return nil
    }
    
    
    /// 注册类
    ///
    /// - Parameters:
    ///   - Class: Class
    ///   - identifier: identifier
    public func register(_ Class: AnyClass, forViewWithReuseIdentifier identifier: String) {
        self.layout?.register(Class, forItemWithReuseIdentifier: identifier)
    }
    
    
    /// 获取重用View
    ///
    /// - Parameters:
    ///   - identifier: identifier
    ///   - index: index
    /// - Returns: UIView
    public func dequeueReusableView(withReuseIdentifier identifier: String, for index: Int) -> UIView {
        return self.layout!.dequeueReusableItem(withReuseIdentifier: identifier, for: index) as! UIView
    }
    
    
    /// 滚动到指定索引
    ///
    /// - Parameters:
    ///   - index: index
    ///   - animate: animate
    public func scrollToView(at index: Int, animate: Bool) {
        self.layout?.scrollToItem(at: index, animate: animate)
    }
    
    
    /// 刷新数据
    public func updateData() {
       self.layout?.updateData()
    }
    
    /// 重新加载数据
    public func reloadData() {
        self.layout?.reloadData()
    }
}


// MARK: - <#PagerViewLayoutDataSource#>
extension PagerView: PagerViewLayoutDataSource {
    
    public func numberOfItemsInPagerViewLayout() -> Int {
        return self.dataSource.numberOfViewsInPagerView()
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, itemFor index: Int, prefetching: Bool) -> AnyObject {
        return self.dataSource.pagerView(self, viewFor: index, prefetching: prefetching)
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, viewForItem item: AnyObject, at index: Int) -> UIView {
        return item as! UIView
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, addVisibleItem item: AnyObject, at index: Int) {
        let visibleView = item as! UIView
        self.delegate?.pagerView(self, willAppear: visibleView, for: index)
        pagerViewLayout.scrollView.addSubview(visibleView)
        self.delegate?.pagerView(self, didAppear: visibleView, for: index)
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, removeInVisibleItem item: AnyObject, at index: Int) {
        
        let invisibleView = item as! UIView
        self.delegate?.pagerView(self, willDisappear: invisibleView, for: index)
        invisibleView.removeFromSuperview()
        self.delegate?.pagerView(self, didDisappear: invisibleView, for: index)
    }
}


// MARK: - PagerViewLayoutDelegate
extension PagerView: PagerViewLayoutDelegate {
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool) {
        self.delegate?.pagerView(self, transitionFrom: fromIndex, to: toIndex, animated: animated)
    }
    
    public func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        self.delegate?.pagerView(self, transitionFrom: fromIndex, to: toIndex, progress: progress)
    }
    
    public func pagerViewLayoutDidScroll(_ pagerViewLayout: PagerViewLayout) {
        self.delegate?.pagerViewDidScroll(self)
    }
    
    public func pagerViewLayoutWillBeginDragging(_ pagerViewLayout: PagerViewLayout) {
        self.willBeginScrollingAnimate(true)
    }
    
    public func pagerViewLayoutWillBeginScroll(toView pagerViewLayout: PagerViewLayout, animate: Bool) {
        self.didEndScrollingAnimate(animate)
    }
    
    public func pagerViewLayoutDidEndDecelerating(_ pagerViewLayout: PagerViewLayout) {
        self.didEndScrollingAnimate(true)
    }
    
    public func pagerViewLayoutDidEndScroll(toView pagerViewLayout: PagerViewLayout, animate: Bool) {
        self.didEndScrollingAnimate(animate)
    }
    
    public func pagerViewLayoutDidEndScrollingAnimation(_ pagerViewLayout: PagerViewLayout) {
        self.didEndScrollingAnimate(true)
    }
    
}
