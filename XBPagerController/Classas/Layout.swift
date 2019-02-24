//
//  Layout.swift
//  XBPagerController
//
//  Created by xiaobin liu on 2019/2/22.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Foundation


/// MARK - 布局
public protocol Layout: NSObjectProtocol {
    
    associatedtype Element
}

public protocol LayoutDataSouces: Layout {
    
    /// 项目数量
    ///
    /// - Returns: 数量
    func numberOfItemsInPagerViewLayout() -> Int
    
    
    /// 如果项目是预加载，预取项
    ///
    /// - Parameters:
    ///   - pagerViewLayout: pagerViewLayout
    ///   - index: index
    ///   - prefetching: prefetching
    /// - Returns: Any
    func pagerViewLayout(_ pagerViewLayout: CustomLayot<Element>, itemFor index: Int, prefetching: Bool) -> Element
}





public class CustomLayot<T>: NSObject, Layout {
    
    public typealias Element = T
    
    public var cache: MemoryCache = {
        let temCache = MemoryCache()
        return temCache
    }()
}


/// MARK - 尝试
public class PagerViewDemo: UIView, LayoutDataSouces {
    
    public typealias Element = UIView
    
    public func numberOfItemsInPagerViewLayout() -> Int {
        return 0
    }
    
    public func pagerViewLayout(_ pagerViewLayout: CustomLayot<PagerViewDemo.Element>, itemFor index: Int, prefetching: Bool) -> PagerViewDemo.Element {
        return UIView()
    }
    
    
}
