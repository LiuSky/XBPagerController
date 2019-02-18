//
//  PagerViewLayout.swift
//  XBPagerController
//
//  Created by xiaobin liu on 2019/2/18.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


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
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, itemFor index: Int, prefetching: Bool) -> AnyClass
    

    /// 返回项的视图
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    /// - Returns: UIView
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, viewForItem item: AnyClass, at index: Int) -> UIView
    
    
    /// 添加显示项
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, addVisibleItem item: AnyClass, at index: Int)
    
    
    
    /// 移除显示项
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, removeInVisibleItem item: AnyClass, at index: Int)
    
    
    
    /// 返回项的控制器视图
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - item: item
    ///   - index: index
    /// - Returns: UIViewController
    @objc optional func pagerViewLayout(_ pagerViewLayout: PagerViewLayout, viewControllerForItem item: AnyClass, at index: Int) -> UIViewController
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
    private(set) var cacheItem: NSCache<NSNumber, AnyObject> = {
        let temPagerAutoPurgeCache = NSCache<NSNumber, AnyObject>()
        temPagerAutoPurgeCache.countLimit = 16 //默认16
        return temPagerAutoPurgeCache
    }()
    
    /// 自动缓存(默认true)
    public var autoMemoryCache: Bool = true
    
    /// 预加载左右项目的数量(默认0)
    public var prefetchItemCount: Int = 0
    
    /// 因为当父视图添加子视图(有tableView)时会调用relodData，如果设置Yes会进行优化。默认不
    public var prefetchItemWillAddToSuperView: Bool = false
    
    /// 预取范围
    private(set) var prefetchRange: NSRange = NSMakeRange(0, 0)
    
    /// 可见范围
    private(set) var visibleRange: NSRange = NSMakeRange(0, 0)
    
    /// 可见索引数组(记得修改)
    private(set) var visibleIndexs: [NSNumber] = []
    
    /// 可见项数组
    private(set) var visibleItems: [AnyClass] = []
    
    /// 进度动画是否启用
    public var progressAnimateEnabel: Bool = true
    
    /// 默认false，当滚动可见范围更改时将添加项。如果是，只在滚动动画结束时添加项目，建议设置prefetchItemCount 1或更多
    public var addVisibleItemOnlyWhenScrollAnimatedEnd: Bool = false
    
    /// 默认0.5，当滚动进度百分比将更改索引时，只有progressAnimateEnabel是NO或不实现委托transitionFromIndex: toIndex: progress:
    public var changeIndexWhenScrollProgress: CGFloat = 0.5
    
    /// 可见索引字典
    private lazy var visibleIndexItems: [NSNumber : AnyClass] = [:]
    
    /// 预加载项目字典
    private lazy var prefetchIndexItems: [NSNumber : AnyClass] = [:]
    
    /// 注册唯一标示类或者Nib
    private lazy var reuseIdentifyClassOrNib: [String: AnyClass] = [:]
    
    /// 初始化
    ///
    /// - Parameter scrollView: <#scrollView description#>
    public init(_ scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
    }
}



// MARK: - public func
extension PagerViewLayout {
    
    /// 根据索引获取项目
    public func item(for idx: Int) -> AnyClass? {
        
//        let index: NSNumber = NSNumber(integerLiteral: idx)
//
//        let visibleItem = self.visibleIndexs
        
//        // 1.from visibleViews
//        id visibleItem = [_visibleIndexItems objectForKey:index];
//        if (!visibleItem && _prefetchItemCount > 0) {
//            // 2.from prefetch
//            visibleItem = [_prefetchIndexItems objectForKey:index];
//        }
//        if (!visibleItem) {
//            // 3.from cache
//            visibleItem = [self cacheItemForKey:index];
//        }
//        return visibleItem;
        return nil
    }
    
    
    /// 获取View
    ///
    /// - Parameters:
    ///   - item: item
    ///   - index: index
    /// - Returns: UIView
    public func view(forItem item: AnyClass, at index: Int) -> UIView {
        
        guard let temDataSource = self.dataSource else {
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
    public func viewController(forItem item: AnyClass, at index: Int) -> UIViewController? {
        
        if self.dataSource?.responds(to: #selector(self.dataSource?.pagerViewLayout(_:viewControllerForItem:at:))) ?? false {
           return self.dataSource!.pagerViewLayout!(self, viewControllerForItem: item, at: index)
        }
        return nil
    }
    
    
    /// 视图索引位置
    ///
    /// - Parameter index: <#index description#>
    /// - Returns: <#return value description#>
    public func frameForItem(at index: Int) -> CGRect {
        
        var frame = self.frameForItemAtIndex(index: index, frame: self.scrollView.frame)
        if adjustScrollViewInset {
            frame.size.height = frame.size.height - self.scrollView.contentInset.top
        }
        return frame
    }
    
    
    /// 注册类
    ///
    /// - Parameters:
    ///   - Class: Class
    ///   - identifier: identifier
    public func register(_ viewClass: AnyClass, forItemWithReuseIdentifier identifier: String) {
        self.reuseIdentifyClassOrNib[identifier] = viewClass
    }
    
    
    /// 使用可重用标识符获取项
    ///
    /// - Parameters:
    ///   - identifier: identifier
    ///   - index: index
    /// - Returns: AnyClass
    public func dequeueReusableItem(withReuseIdentifier identifier: String, for index: Int) -> AnyClass {
        assert(self.reuseIdentifyClassOrNib.count != 0, "you don't register any identifiers!")
        
        let item = self
        
    }
    
}


// MARK: - private func
extension PagerViewLayout {
    
    private func frameForItemAtIndex(index: Int, frame: CGRect) -> CGRect {
        return CGRect(x: CGFloat(CGFloat(index) * frame.width), y: 0, width: frame.width, height: frame.height)
    }
}
