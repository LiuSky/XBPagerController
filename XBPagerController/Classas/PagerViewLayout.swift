//
//  PagerViewLayout.swift
//  XBPagerController
//
//  Created by xiaobin liu on 2019/2/18.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// 方向
///
/// - left: <#left description#>
/// - right: <#right description#>
public enum PagerScrollingDirection: Int {
    case left
    case right
}


/// MARK - 数据源
@objc public protocol PagerViewLayoutDataSource: NSObjectProtocol {
    
    /// 项目数量
    ///
    /// - Returns: 数量
    func numberOfItemsInPagerViewLayout() -> Int
    
    
    /// 如果项目是预加载，预取将是
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - index: index
    ///   - prefetching: prefetching
    /// - Returns: Any
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, itemFor index: Int, prefetching: Bool) -> AnyObject
    

    /// 返回项的视图
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    /// - Returns: UIView
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, viewForItem item: AnyObject, at index: Int) -> UIView
    
    
    /// 添加显示项
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, addVisibleItem item: AnyObject, at index: Int)
    
    
    
    /// 移除显示项
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, removeInVisibleItem item: AnyObject, at index: Int)
    
    
    
    /// 返回项的控制器视图
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    /// - Returns: UIViewController
    @objc optional func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, viewControllerForItem item: AnyObject, at index: Int) -> UIViewController
}



/// MARK - 协议
@objc public protocol PagerViewLayoutDelegate: NSObjectProtocol {
    
    
    /// 过渡动画定制
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - animated: animated
    @objc optional func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, transitionFrom fromIndex: Int, to toIndex: Int, animated: Bool)
    
    
    
    /// 过渡动画进度
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - progress: progress
    @objc optional func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, transitionFrom fromIndex: Int, to toIndex: Int, progress: CGFloat)
    
    
    /// 开始滚动方法
    ///
    /// - Parameter pagerViewLayout: pagerViewLayout
    @objc optional func pagerViewLayoutDidScroll(_ pagerViewLayout: PagerViewLayout)
    
    
    /// 将要开始滚动方法
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - animate: animate
    @objc optional func pagerViewLayoutWillBeginScroll(toView pagerViewLayout: PagerViewLayout, animate: Bool)
    
    
    /// 完成滚动方法
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - animate: animate
    @objc optional func pagerViewLayoutDidEndScroll(toView pagerViewLayout: PagerViewLayout, animate: Bool)
    
    
    /// 将要开始拖拽方法
    ///
    /// - Parameter pagerViewLayout: pagerViewLayout
    @objc optional func pagerViewLayoutWillBeginDragging(_ pagerViewLayout: PagerViewLayout)
    
    
    /// 完成拖拽方法
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - decelerate: decelerate
    @objc optional func pagerViewLayoutDidEndDragging(_ pagerViewLayout: PagerViewLayout, willDecelerate decelerate: Bool)
    
    
    /// 将要滑动减速方法
    ///
    /// - Parameter pagerViewLayout: pagerViewLayout
    @objc optional func pagerViewLayoutWillBeginDecelerating(_ pagerViewLayout: PagerViewLayout)
    
    
    /// 完成滑动减速方法
    ///
    /// - Parameter pagerViewLayout: pagerViewLayout
    @objc optional func pagerViewLayoutDidEndDecelerating(_ pagerViewLayout: PagerViewLayout)
    

    /// 当滚动视图动画完成后,调用该方法,如果没有动画,那么该方法将不被调用
    ///
    /// - Parameter pagerViewLayout: pagerViewLayout
    @objc optional func pagerViewLayoutDidEndScrollingAnimation(_ pagerViewLayout: PagerViewLayout)

}


/// MARK - PagerViewLayout
public class PagerViewLayout: NSObject {
    
    /// 数据源
    public weak var dataSource: PagerViewLayoutDataSource?
    
    /// 回调
    public weak var delegate: PagerViewLayoutDelegate?
    
    /// 滚动View
    private(set) var scrollView: UIScrollView!
    
    /// 如果ViewController的automaticallycontrosscrollviewinsets True，会导致帧问题，你可以设置True，默认设置True
    public var adjustScrollViewInset: Bool = true
    
    /// 项数量
    private(set) var countOfPagerItems: Int = 0
    
    /// 当前选中项
    private(set) var curIndex = -1
    
    /// 缓存项
    private(set) lazy var memoryCache: MemoryCache = {
        let temPagerAutoPurgeCache = MemoryCache()
        temPagerAutoPurgeCache.countLimit = 16 //默认16
        return temPagerAutoPurgeCache
    }()
    
    /// 自动缓存(默认true)
    public var autoMemoryCache: Bool = true {
        didSet {
            if autoMemoryCache == false {
                memoryCache.removeAllObjects()
            }
        }
    }
    
    /// 预加载左右项目的数量(默认0)
    public var prefetchItemCount: Int = 0 {
        didSet {
            if prefetchItemCount <= 0 && prefetchIndexItems != nil {
                prefetchIndexItems = nil
            }
        }
    }
    
    /// 因为当父视图添加子视图(有tableView)时会调用relodData，如果设置true会进行优化。默认false
    public var prefetchItemWillAddToSuperView: Bool = false
    
    /// 预取范围
    private(set) var prefetchRange: NSRange = NSMakeRange(0, 0)
    
    /// 可见范围
    private(set) var visibleRange: NSRange = NSMakeRange(0, 0)
    
    /// 可见索引数组(记得修改)
    public var visibleIndexs: [NSNumber]? {
        return self.visibleIndexItems?.map { $0.key }
    }
    
    /// 可见项数组
    public var visibleItems: [AnyObject]? {
        return self.visibleIndexItems?.map { $0.value }
    }
    
    /// 进度动画是否启用
    public var progressAnimateEnabel: Bool = true
    
    /// 默认false，当滚动可见范围更改时将添加项。如果是，只在滚动动画结束时添加项目，建议设置prefetchItemCount 1或更多
    public var addVisibleItemOnlyWhenScrollAnimatedEnd: Bool = false
    
    /// 默认0.5，当滚动进度百分比将更改索引时，只有progressAnimateEnabel是NO或不实现委托transitionFromIndex: toIndex: progress:
    public var changeIndexWhenScrollProgress: CGFloat = 0.5
    
    /// 可见索引字典
    private var visibleIndexItems: [NSNumber : AnyObject]?
    
    /// 预加载项目字典
    private var prefetchIndexItems: [NSNumber : AnyObject]?
    
    /// 注册唯一标识类
    private lazy var reuseIdentifyClass: [String: AnyObject] = [:]
    
    /// 重用项
    private lazy var reuseIdentifyItems: [String: AnyObject] = [:]
    
    /// 上一项偏差x
    private var preOffsetX: CGFloat = 0
    
    /// 已经刷新
    private var didReloadData = false
    
    /// 已经布局子View
    private var didLayoutSubViews = false
    
    /// 首先滚动到索引
    private var firstScrollToIndex: Int = 0
    
    /// 滚动动画
    private var scrollAnimated = true
    
    /// 需要布局内容
    private var needLayoutContent: Bool = false
    
    /// 是否点击滚动
    private var isTapScrollMoved: Bool = false
    
    /// 滚动View Observable
    private var scrollViewKeyValueObservation: NSKeyValueObservation?
    
    /// 初始化
    ///
    /// - Parameter scrollView: <#scrollView description#>
    public init(_ scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        configureScrollView()
        addKeyValueObservation()
    }
    
    
    deinit {
        scrollView.delegate = nil
        reuseIdentifyItems.removeAll()
        reuseIdentifyClass.removeAll()
        clearMemoryCache()
    }
}


// MARK: - configure
extension PagerViewLayout {
    
    /// 配置滚动View
    private func configureScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
    }
    
    
    /// 重置属性
    private func resetPropertys() {
        
        clearMemoryCache()
        removeVisibleItems()
        scrollAnimated = false
        curIndex = -1
        preOffsetX = 0
    }
}


// MARK: - public func
extension PagerViewLayout {
    
    
    /// MARK - 重新加载
    public func reloadData() {
        resetPropertys()
        updateData()
    }
    
    /// 更新不重置属性(curIndex)
    public func updateData() {
        
        clearMemoryCache()
        didReloadData = true
        countOfPagerItems = dataSource?.numberOfItemsInPagerViewLayout() ?? 0
        setNeedLayout()
    }
    
    
    /// 滚动到索引项
    ///
    /// - Parameters:
    ///   - index: 索引
    ///   - animate: 动画
    public func scrollToItem(at index: Int, animate: Bool) {
        
        if index < 0 || index >= countOfPagerItems {
            if didReloadData == false && index >= 0 {
                firstScrollToIndex = index
            }
            return
        }
        
        if didLayoutSubViews == false && scrollView.frame.isEmpty {
            firstScrollToIndex = index
        }
        
        scrollViewWillScroll(to: scrollView, animate: animate)
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * scrollView.frame.width, y: 0), animated: false)
        scrollViewDidScroll(to: scrollView, animate: animate)
        
    }
    
    
    /// 根据索引获取项目
    public func item(for idx: Int) -> AnyObject? {
        
        let index: NSNumber = NSNumber(integerLiteral: idx)
        var visibleItem = visibleIndexItems?[index]
        
        /// 从可见视图
        if visibleItem == nil && prefetchItemCount > 0 {
            
            /// 从预取视图
            visibleItem = prefetchIndexItems?[index]
        }
        
        if visibleItem == nil {
            /// 从缓存
            visibleItem = cacheItem(forKey: index)
        }
        return visibleItem
    }
    
    
    /// 获取View
    ///
    /// - Parameters:
    ///   - item: item
    ///   - index: index
    /// - Returns: UIView
    public func view(forItem item: AnyObject, at index: Int) -> UIView {
        
        guard let temDataSource = dataSource else {
            Swift.fatalError("数据源协议必须实现", file: #file, line: #line)
        }
        
        let view = temDataSource.pagerViewLayout(self, viewForItem: item, at: index)
        return view
    }
    
    
    /// 获取控制器
    ///
    /// - Parameters:
    ///   - item: item
    ///   - index: index
    /// - Returns: UIViewController
    public func viewController(forItem item: AnyObject, at index: Int) -> UIViewController? {
        
        if dataSource?.responds(to: #selector(dataSource?.pagerViewLayout(_:viewControllerForItem:at:))) ?? false {
            return dataSource!.pagerViewLayout!(self, viewControllerForItem: item, at: index)
        }
        return nil
    }
    
    
    /// 视图索引位置
    ///
    /// - Parameter index: index
    /// - Returns: CGRect
    public func frameForItem(at index: Int) -> CGRect {
        
        var frame = frameForItemAtIndex(index: index, frame: scrollView.frame)
        if adjustScrollViewInset {
            frame.size.height = frame.size.height - scrollView.contentInset.top
        }
        return frame
    }
}


// MARK: - register && dequeue
extension PagerViewLayout {
    
    
    /// 注册类
    ///
    /// - Parameters:
    ///   - Class: Class
    ///   - identifier: identifier
    public func register(_ viewClass: AnyClass, forItemWithReuseIdentifier identifier: String) {
        reuseIdentifyClass[identifier] = viewClass
    }

    
    /// 使用可重用标识符获取项
    ///
    /// - Parameters:
    ///   - identifier: identifier
    ///   - index: index
    /// - Returns: AnyClass
    public func dequeueReusableItem(withReuseIdentifier identifier: String, for index: Int) -> Any? {
        
        assert(self.reuseIdentifyClass.count != 0, "you don't register any \(identifier)")
        
        var item = reuseIdentifyItems[identifier] as? NSObject
        if item != nil {
            reuseIdentifyItems.removeValue(forKey: identifier)
            return item
        }
        
        guard let itemClass = reuseIdentifyClass[identifier] else {
            assert(false, "you don't register any \(identifier)!")
            return nil
        }
        
        if let viewType = itemClass as? UIView.Type {
            item = viewType.init()
        } else if let viewController = itemClass as? UIViewController.Type {
            item = viewController.init()
        }
        
        if let temItem = item {
            temItem.pagerReuseIdentifyKey = identifier
            let view = dataSource!.pagerViewLayout(self, viewForItem: temItem, at: index)
            view.frame = self.frameForItem(at: index)
            return temItem
            
        } else {
            assert(false, "you register \(identifier) is not class")
            return nil
        }
    }
    
    private func enqueueReusableItem(_ reuseItem: NSObject, prefetchRange: NSRange, at index: Int) {
        
        if reuseItem.pagerReuseIdentifyKey.count == 0 ||
            NSLocationInRange(index, prefetchRange) {
            return
        }
        reuseIdentifyItems[reuseItem.pagerReuseIdentifyKey] = reuseItem
    }
}


// MARK: - layout content
extension PagerViewLayout {
    
    /// 设置布局
    private func setNeedLayout() {
        
        guard let temDataSource = self.dataSource else {
            Swift.fatalError("数据源协议必须实现", file: #file, line: #line)
        }
        
        if countOfPagerItems <= 0 {
            countOfPagerItems = temDataSource.numberOfItemsInPagerViewLayout()
        }
        
        needLayoutContent = true
        if curIndex >= countOfPagerItems {
            curIndex = countOfPagerItems - 1
        }
        
        var needLayoutSubViews = false
        if didLayoutSubViews == false && !scrollView.frame.isEmpty && firstScrollToIndex < countOfPagerItems {
            didLayoutSubViews = true
            needLayoutSubViews = true
        }
        
        // 2.set contentSize and offset
        let contentWidth = scrollView.frame.width
        scrollView.contentSize = CGSize(width: CGFloat(countOfPagerItems) * contentWidth, height: 0)
        scrollView.contentOffset = CGPoint(x: CGFloat(max(needLayoutSubViews ? firstScrollToIndex : curIndex, 0)) * contentWidth, y: scrollView.contentOffset.y)
        
        
        // 3.layout content
        if curIndex < 0 || needLayoutSubViews {
            scrollViewDidScroll(scrollView)
        } else {
            layoutIfNeed()
        }
    }
    
    /// 立即布局
    private func layoutIfNeed() {
        
        guard !scrollView.frame.isEmpty else {
            return
        }
        
        // 1.caculate visible range
        let offsetX = scrollView.contentOffset.x
        let visibleRange = visibleRangWithOffset(offset: offsetX, width: scrollView.frame.width, maxIndex: countOfPagerItems)
        if NSEqualRanges(self.visibleRange, visibleRange) && !needLayoutContent {
            //可见范围不变
            return
        }
        
        self.visibleRange = visibleRange
        needLayoutContent = false
        
        let afterPrefetchIfNoVisibleItems = visibleIndexItems == nil ? true: false
        if !afterPrefetchIfNoVisibleItems {
            // 2.prefetch left and right Items
            addPrefetchItemsOutOfVisibleRange(self.visibleRange)
        }
        
        //3.remove invisible Items
        removeVisibleItemsOutOfVisibleRange(self.visibleRange)
        
        
        //4.add visiible Items
        addVisibleItems(inVisibleRange: self.visibleRange)
        if afterPrefetchIfNoVisibleItems {
            addPrefetchItemsOutOfVisibleRange(self.visibleRange)
        }
    }
}


// MARK: - remove && add visibleViews
extension PagerViewLayout {
    
    /// 移除可见项目数组
    private func removeVisibleItems() {
        
        scrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        visibleIndexItems = nil
        prefetchIndexItems = nil
        reuseIdentifyItems.removeAll()
    }
    
    
    /// 移除可见项目范围项
    ///
    /// - Parameter visibleRange: <#visibleRange description#>
    private func removeVisibleItemsOutOfVisibleRange(_ visibleRange: NSRange) {
        
        visibleIndexItems?.forEach {
            let index = $0.key.intValue
            if NSLocationInRange(index, visibleRange) == false {
                removeInvisibleItem($0.value, at: index)
            }
        }
    }
    
    
    /// 移除可见项
    ///
    /// - Parameters:
    ///   - invisibleItem: <#invisibleItem description#>
    ///   - index: <#index description#>
    private func removeInvisibleItem(_ invisibleItem: AnyObject, at index: Int) {
        
        let invisibleView = self.view(forItem: invisibleItem, at: index)
        if invisibleView.superview == nil {
            return
        }
        
        self.dataSource?.pagerViewLayout(self, removeInVisibleItem: invisibleItem, at: index)
        
        let reuseItem = invisibleItem as! NSObject
        if reuseIdentifyClass.count > 0 &&
            reuseItem.pagerReuseIdentifyKey.count > 0 {
            enqueueReusableItem(invisibleView, prefetchRange: prefetchRange, at: index)
        } else {
            cacheItem(invisibleView, forKey: NSNumber(integerLiteral: index))
        }
    }
    
    /// 添加可见项
    ///
    /// - Parameter visibleRange: visibleRange
    private func addVisibleItems(inVisibleRange visibleRange: NSRange) {
        
        var visibleIndexItems: [NSNumber: AnyObject] = [:]
        
        for idx in visibleRange.location..<visibleRange.location + visibleRange.length {
            // from visibleViews,prefetch,cache
            var visibleItem = item(for: idx)
            if visibleItem == nil && (!addVisibleItemOnlyWhenScrollAnimatedEnd || visibleRange.length == 1) {
                
                visibleItem = dataSource?.pagerViewLayout(self, itemFor: idx, prefetching: false)
            }
            
            if let temVisibleItem = visibleItem {
                addVisibleItem(temVisibleItem, at: idx)
                visibleIndexItems[NSNumber(integerLiteral: idx)] = temVisibleItem
            }
        }
        
        if visibleIndexItems.count > 0 {
            self.visibleIndexItems = visibleIndexItems
        } else {
            self.visibleIndexItems = nil
        }
    }
    
    
    ///  添加可见项
    ///
    /// - Parameters:
    ///   - visibleItem: visibleItem
    ///   - index: index
    private func addVisibleItem(_ visibleItem: AnyObject, at index: Int) {
        
        let view = self.view(forItem: visibleItem, at: index)
        if view.superview != nil && view.superview != scrollView {
            view.removeFromSuperview()
        }
        
        let frame = frameForItem(at: index)
        if view.frame != frame {
            view.frame = frame
        }
        
        if !prefetchItemWillAddToSuperView && view.superview != nil {
            return
        }
        
        if prefetchItemWillAddToSuperView && view.superview != nil {
            
            let viewController = self.viewController(forItem: visibleItem, at: index)
            if viewController == nil || viewController?.presentationController != nil {
                return
            }
        }
        
        self.dataSource?.pagerViewLayout(self, addVisibleItem: visibleItem, at: index)
    }
    
    
    /// 添加超出可见范围的预取项
    ///
    /// - Parameter visibleRange: <#visibleRange description#>
    func addPrefetchItemsOutOfVisibleRange(_ visibleRange: NSRange) {
        
        guard prefetchItemCount > 0 else {
            return
        }
        
        let prefetchRange = prefetchRangeWithVisibleRange(visibleRange: visibleRange,
                                                          prefetchItemCount: prefetchItemCount,
                                                          countOfPagerItems: countOfPagerItems)
        if visibleRange.length == 1 {
            
            var prefetchIndexItems: [NSNumber: AnyObject] = [:]
            for index in prefetchRange.location..<NSMaxRange(prefetchRange) {
                var prefetchItem: AnyObject? = nil
                if NSLocationInRange(index, visibleRange) {
                    prefetchItem = visibleIndexItems?[NSNumber(integerLiteral: index)]
                } else {
                    prefetchItem = prefetchInvisibleItem(at: index)
                }
                if let temPrefetchItem = prefetchItem {
                    prefetchIndexItems[NSNumber(integerLiteral: index)] = temPrefetchItem
                }
            }
            
            let haveReuseIdentifyClass = reuseIdentifyClass.count > 0
            if haveReuseIdentifyClass || prefetchItemWillAddToSuperView {
                
                self.prefetchIndexItems?.forEach { element in
                    
                    let index = element.key.intValue
                    if haveReuseIdentifyClass {
                        enqueueReusableItem(element.value as! NSObject, prefetchRange: prefetchRange, at: index)
                    }
                    if prefetchItemWillAddToSuperView && !NSLocationInRange(index, prefetchRange) {
                        let view = self.view(forItem: element.value, at: index)
                        if view.superview == scrollView && self.visibleIndexItems?[element.key] == nil {
                            view.removeFromSuperview()
                        }
                        
                    }
                    
                }
            }
            
            if prefetchIndexItems.count > 0 {
                self.prefetchRange = prefetchRange
                self.prefetchIndexItems = prefetchIndexItems
            } else {
                self.prefetchRange = NSMakeRange(0, 0)
                self.prefetchIndexItems = nil
            }
        } else if NSIntersectionRange(visibleRange, self.prefetchRange).length == 0 {
            
            if prefetchItemWillAddToSuperView {
                
                self.prefetchIndexItems?.forEach { element in
                    
                    let view = self.view(forItem: element.value, at: element.key.intValue)
                    if view.superview == scrollView && self.visibleIndexItems?[element.key] == nil {
                        view.removeFromSuperview()
                    }
                }
            }
            self.prefetchRange = NSMakeRange(0, 0)
            self.prefetchIndexItems = nil
        }
    }
    
    
    private func prefetchInvisibleItem(at index: Int) -> UIView {
        
        var prefetchItem = self.prefetchIndexItems?[NSNumber(integerLiteral: index)]
        if prefetchItem == nil {
            prefetchItem = self.visibleIndexItems?[NSNumber(integerLiteral: index)]
        }
        
        if prefetchItem == nil {
            prefetchItem = self.cacheItem(forKey: NSNumber(integerLiteral: index))
        }
        
        if prefetchItem == nil {
            
            prefetchItem = dataSource!.pagerViewLayout(self, itemFor: index, prefetching: true)
            let view = self.view(forItem: prefetchItem!, at: index)
            let frame = self.frameForItem(at: index)
            if view.frame != frame {
                view.frame = frame
            }
            if prefetchItemWillAddToSuperView && view.superview != scrollView {
                scrollView.addSubview(view)
            }
        }
        return prefetchItem as! UIView
    }
}



// MARK: - caculate index
extension PagerViewLayout {
    
    /// 计算索引
    ///
    /// - Parameters:
    ///   - offsetX: <#offsetX description#>
    ///   - direction: <#direction description#>
    private func caculateIndex(withOffsetX offsetX: CGFloat, direction: PagerScrollingDirection) {
        
        guard !scrollView.frame.isEmpty else {
            return
        }
        
        if countOfPagerItems <= 0 {
            curIndex = -1
            return
        }
        
        let width = scrollView.frame.width
        var index = 0
        var percentChangeIndex = changeIndexWhenScrollProgress
        if changeIndexWhenScrollProgress >= 1.0 || self.progressCaculateEnable() {
            percentChangeIndex = 0.999999999
        }
        
        if direction == .left {
            index = Int(ceil(offsetX / width - percentChangeIndex))
        } else {
            index = Int(floor(offsetX / width + percentChangeIndex))
        }
        
        if index < 0 {
            index = 0
        } else if index >= countOfPagerItems {
            index = countOfPagerItems - 1
        }
        
        if index == curIndex {
            return
        }
        
        let fromIndex = max(curIndex, 0)
        self.curIndex = index
        self.delegate?.pagerViewLayout?(self, transitionFrom: fromIndex, to: curIndex, animated: scrollAnimated)
        scrollAnimated = true
    }
    
    
    
    /// 计算索引进度
    ///
    /// - Parameters:
    ///   - offsetX: <#offsetX description#>
    ///   - direction: <#direction description#>
    private func caculateIndexByProgress(withOffsetX offsetX: CGFloat, direction: PagerScrollingDirection) {
        
        guard !scrollView.frame.isEmpty else {
            return
        }
        
        if countOfPagerItems <= 0 {
            curIndex = -1
            return
        }
        
        let width = scrollView.frame.width
        let floadIndex = offsetX / width
        let floorIndex: Int = Int(floor(floadIndex))
        if floorIndex < 0 || floorIndex >= countOfPagerItems || Int(floadIndex) > countOfPagerItems-1 {
            return
        }
        
        var progress = offsetX / width - CGFloat(floorIndex)
        var fromIndex = 0, toIndex = 0
        if direction == .left {
            fromIndex = floorIndex
            toIndex = min(countOfPagerItems - 1, fromIndex + 1)
            if fromIndex == toIndex && toIndex == countOfPagerItems-1 {
                fromIndex = countOfPagerItems - 2
                progress = 1.0
            }
        } else {
            
            toIndex = floorIndex
            fromIndex = min(countOfPagerItems - 1, toIndex + 1)
            progress = 1.0 - progress
        }
        
        self.delegate?.pagerViewLayout?(self, transitionFrom: fromIndex, to: toIndex, progress: progress)
    }
    
    
    /// 进度是否启用
    ///
    /// - Returns: <#return value description#>
    private func progressCaculateEnable() -> Bool {
        let delegateFlags = self.delegate?.responds(to: #selector(self.delegate?.pagerViewLayout(_:transitionFrom:to:progress:))) ?? false
        return delegateFlags && progressAnimateEnabel && !isTapScrollMoved
    }
}


// MARK: - memoryCache
extension PagerViewLayout {
    
    
    /// 清除内存缓存
    private func clearMemoryCache() {
        if autoMemoryCache {
            memoryCache.removeAllObjects()
        }
    }
    
    
    /// 设置缓存项
    ///
    /// - Parameters:
    ///   - item: item
    ///   - key: key
    private func cacheItem(_ item: AnyObject, forKey key: NSNumber) {
        
        if autoMemoryCache {
            
            if let cacheItem = memoryCache.object(forKey: key),
                cacheItem === item {
                return
            }
            memoryCache.setObject(item, forKey: key)
        }
    }
    
    
    /// 查找缓存项
    ///
    /// - Parameter key: <#key description#>
    /// - Returns: <#return value description#>
    private func cacheItem(forKey key: NSNumber) -> AnyObject? {
        if autoMemoryCache {
            return memoryCache.object(forKey: key)
        }
        return nil
    }
}


// MARK: - UIScrollViewDelegate
extension PagerViewLayout: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let _ = scrollView.superview else {
            return
        }
        
        let offsetX = scrollView.contentOffset.x
        let direction: PagerScrollingDirection = offsetX >= preOffsetX ? .left : .right
        
        if progressCaculateEnable() {
           self.caculateIndexByProgress(withOffsetX: offsetX, direction: direction)
        }
        self.caculateIndex(withOffsetX: offsetX, direction: direction)
        
        self.layoutIfNeed()
        isTapScrollMoved = false
        self.delegate?.pagerViewLayoutDidScroll?(self)
        
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        preOffsetX = scrollView.contentOffset.x
        self.delegate?.pagerViewLayoutWillBeginDragging?(self)
        
    }
    
    private func scrollViewWillScroll(to scrollView: UIScrollView, animate: Bool) {
        
        preOffsetX = scrollView.contentOffset.x
        isTapScrollMoved = true
        scrollAnimated = animate
        self.delegate?.pagerViewLayoutWillBeginScroll?(toView: self, animate: animate)
    }
    
    private func scrollViewDidScroll(to scrollView: UIScrollView, animate: Bool) {
        self.delegate?.pagerViewLayoutDidEndScroll?(toView: self, animate: animate)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.pagerViewLayoutDidEndDragging?(self, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.pagerViewLayoutWillBeginDecelerating?(self)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.pagerViewLayoutDidEndDecelerating?(self)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.delegate?.pagerViewLayoutDidEndScrollingAnimation?(self)
    }
    
}

// MARK: - Observer
extension PagerViewLayout {
    
    /// 添加ScrollView观察者
    private func addKeyValueObservation() {
        
        scrollViewKeyValueObservation?.invalidate()
        scrollViewKeyValueObservation = scrollView.observe(\.frame, options: [.new, .old]) { [weak self] (scrollView, change) in
            guard let self = self else { return }
            guard change.newValue != change.oldValue else { return }
            self.setNeedLayout()
        }
    }
}



// MARK: - Frame
extension PagerViewLayout {
    
    private func frameForItemAtIndex(index: Int, frame: CGRect) -> CGRect {
        return CGRect(x: CGFloat(CGFloat(index) * frame.width), y: 0, width: frame.width, height: frame.height)
    }
    
    
    private func visibleRangWithOffset(offset: CGFloat, width: CGFloat, maxIndex: Int) -> NSRange {
        
        if width <= 0 {
            return NSRange(location: 0, length: 0)
        }
        var startIndex = Int(offset / width)
        var endIndex: Int = Int(ceil((offset + width) / width))
        
        if startIndex < 0 {
            startIndex = 0
        } else if startIndex > maxIndex {
            startIndex = maxIndex
        }
        
        if endIndex > maxIndex {
            endIndex = maxIndex
        }
        
        var length: Int = endIndex - startIndex
        if length > 5 {
            length = 5
        }
        return NSRange(location: startIndex, length: length)
    }
    
    
    private func prefetchRangeWithVisibleRange(visibleRange: NSRange, prefetchItemCount: Int, countOfPagerItems: Int) -> NSRange {
        if prefetchItemCount <= 0 {
            return NSRange(location: 0, length: 0)
        }
        let leftIndex = max(Int(visibleRange.location) - prefetchItemCount, 0)
        let rightIndex = min(Int(visibleRange.location + visibleRange.length) + prefetchItemCount, countOfPagerItems)
        return NSRange(location: leftIndex, length: rightIndex - leftIndex)
    }
}
