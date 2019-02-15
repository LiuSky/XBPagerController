//
//  TabPagerBar.swift
//  XBTabPagerBar
//
//  Created by xiaobin liu on 2019/2/14.
//  Copyright © 2019 Sky. All rights reserved.
//


import UIKit

/// MARK - 数据源协议
public protocol TabPagerBarDataSource: NSObjectProtocol {

    /// 单元格数量
    func numberOfItemsInPagerTabBar() -> Int
    
    /// 单元格协议
    func pagerTabBar(_ pagerTabBar: TabPagerBar, cellForItemAt index: Int) -> TabPagerCellProtocol
}



/// MARK - 回调协议
@objc public protocol TabPagerBarDelegate: NSObjectProtocol {
    
    /// 配置布局
    @objc optional func pagerTabBar(_ pagerTabBar: TabPagerBar, configureLayout layout: TabPagerBarLayout)
    
    /// 如果单元格wdith不是变量，则可以设置layout.cellWidth。否则，您可以实现此返回单元格宽度。单元格宽度不包含单元格边缘
    @objc optional func pagerTabBar(_ pagerTabBar: TabPagerBar, widthForItemAt index: Int) -> CGFloat
    
    /// 选择单元格项
    @objc optional func pagerTabBar(_ pagerTabBar: TabPagerBar, didSelectItemAt index: Int)
    
    /// 将旧单元格转换为具有动画效果的新单元格
    @objc optional func pagerTabBar(_ pagerTabBar: TabPagerBar, transitionFromeCell fromCell: TabPagerCellProtocol?, toCell: TabPagerCellProtocol?, animated: Bool)

    /// 随着进度从一个单元格过渡到另一个单元格
    @objc optional func pagerTabBar(_ pagerTabBar: TabPagerBar, transitionFromeCell fromCell: TabPagerCellProtocol?, toCell: TabPagerCellProtocol?, progress: CGFloat)
}



/// MARK - TabPagerBar
public class TabPagerBar: UIView {
    
    /// 数据源协议
    public weak var dataSource: TabPagerBarDataSource?
    
    /// 回调协议
    public weak var delegate: TabPagerBarDelegate?
    
    /// 布局
    public lazy var layout: TabPagerBarLayout = {
        let temLayout = TabPagerBarLayout(pagerTabBar: self)
        return temLayout
    }()
    
    /// 是否自动滚动到中间
    public var autoScrollItemToCenter: Bool = true
    
    /// 内容边距
    public var contentInset: UIEdgeInsets = .zero
    
    /// 默认数量为0
    private(set) var countOfItems: Int = 0
    
    /// 当前索引
    private(set) var curIndex: Int = 0
    
    /// 进度View
    private(set) lazy var progressView: UIView = {
        let progressView = UIView()
        progressView.backgroundColor = UIColor.red
        return progressView
    }()
    
    /// 背景View
    private var backgroundView: UIView?
    
    /// 列表View
    private(set) lazy var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let temCollectionView = UICollectionView(frame: self.bounds.inset(by: self.contentInset), collectionViewLayout: flowLayout)
        temCollectionView.showsVerticalScrollIndicator = false
        temCollectionView.showsHorizontalScrollIndicator = false
        temCollectionView.backgroundColor = UIColor.clear
        if #available(iOS 10.0, *) {
           temCollectionView.isPrefetchingEnabled = false
        }
        temCollectionView.dataSource = self
        temCollectionView.delegate = self
        return temCollectionView
    }()
    
    /// 是否首个布局
    private var isFirstLayout: Bool = true
    
    /// 已经布局子视图
    private var didLayoutSubViews: Bool = false
    
    
    public init() {
        super.init(frame: CGRect.zero)
        self.config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.config()
    }
    
    /// 配置
    private func config() {
        self.backgroundColor = UIColor.clear
        self.addFixAutoAdjustInsetScrollView()
        self.addCollectionView()
        self.addUnderLineView()
    }
    
    /// 添加修复自动调整设置滚动视图
    private func addFixAutoAdjustInsetScrollView() {
        let view = UIView()
        self.addSubview(view)
    }
    
    /// 添加滚动视图
    private func addCollectionView() {
        self.addSubview(collectionView)
    }
    
    /// 添加线
    private func addUnderLineView() {
        collectionView.addSubview(progressView)
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView?.frame = self.bounds
        let frame = self.bounds.inset(by: self.contentInset)
        let needUpdateLayout = (frame.size.height > 0 && self.collectionView.frame.size.height != frame.size.height) || (frame.size.width > 0 && self.collectionView.frame.size.width != frame.size.width)
        self.collectionView.frame = frame
        if self.didLayoutSubViews == false && self.collectionView.frame.isEmpty == false {
            self.didLayoutSubViews = true
        }
        
        if needUpdateLayout {
            self.layout.invalidateLayout()
        }
        
        if frame.size.height > 0 && frame.size.width > 0 {
            self.layout.adjustContentCellsCenterInBar()
        }
    
        self.isFirstLayout = false
        self.layout.layoutSubViews()
    }
}


// MARK: - public func
extension TabPagerBar {
    
    /// 设置进度条View
    ///
    /// - Parameter progressView: <#progressView description#>
    public func setProgressView(_ progressView: UIView) {
        
        if self.progressView == progressView {
            return
        }
        
        self.progressView.removeFromSuperview()
        self.progressView = progressView
        if self.layout.barStyle == .cover {
            progressView.layer.zPosition = -1
            collectionView.insertSubview(progressView, at: 0)
        } else {
            collectionView.addSubview(progressView)
        }
        
        if self.superview != nil {
            layout.layoutSubViews()
        }
    }
    
    
    /// 设置背景View
    ///
    /// - Parameter backgroundView: <#backgroundView description#>
    public func setBackgroundView(_ backgroundView: UIView) {
        
        if let temBackgroundView = self.backgroundView {
            temBackgroundView.removeFromSuperview()
        }
        
        self.backgroundView = backgroundView
        backgroundView.frame = self.bounds
        self.insertSubview(backgroundView, at: 0)
    }
    
    
    /// 设置布局
    ///
    /// - Parameter layout: <#layout description#>
    public func setLayout(_ layout: TabPagerBarLayout) {
        
        let updateLayout = self.layout != layout
        self.layout = layout
        if updateLayout {
            self.reloadData()
        }
    }
    
    
    /// 注册Cell
    public func register(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    
    /// 注册Cell Nib
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    
    /// 获取可充用的单元格
    ///
    /// - Parameters:
    ///   - identifier: identifier
    ///   - index: index
    /// - Returns: TabPagerCellProtocol
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> TabPagerCellProtocol {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0)) as! TabPagerCellProtocol
        return cell
    }
    
    /// 刷新
    public func reloadData() {
        
        guard let temDataSource = self.dataSource else {
            Swift.fatalError("数据源协议必须实现", file: #file, line: #line)
        }
        
        
        self.countOfItems = temDataSource.numberOfItemsInPagerTabBar()
        if self.curIndex >= self.countOfItems {
            self.curIndex = self.countOfItems - 1
        }
        
        self.delegate?.pagerTabBar?(self, configureLayout: self.layout)
        self.layout.layoutIfNeed()
        self.collectionView.reloadData()
        self.layout.adjustContentCellsCenterInBar()
        self.layout.layoutSubViews()
    }
    
    
    
    /// 滚动到指定项动画
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - animate: animate
    public func scrollToItem(from fromIndex: Int, to toIndex: Int, animate: Bool) {
        
        if toIndex < self.countOfItems && toIndex >= 0 && fromIndex < self.countOfItems && fromIndex >= 0 {
            
            self.curIndex = toIndex
            self.transition(from: fromIndex, to: toIndex, animated: animate)
            if self.autoScrollItemToCenter {
                if self.didLayoutSubViews == false {
                    DispatchQueue.main.async {
                        self.scrollToItem(at: toIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animate)
                    }
                } else {
                    self.scrollToItem(at: toIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animate)
                }
            }
        }
    }
    
    
    /// 滚动到指定项进度
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - progress: progress
    public func scrollToItem(from fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        
        if toIndex < self.countOfItems && toIndex >= 0 && fromIndex < self.countOfItems && fromIndex >= 0 {
            self.transition(from: fromIndex, to: toIndex, progress: progress)
        }
    }
    
    
    
    /// 滚动ScrollItem
    ///
    /// - Parameters:
    ///   - index: <#index description#>
    ///   - scrollPosition: <#scrollPosition description#>
    ///   - animated: <#animated description#>
    public func scrollToItem(at index: Int, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: scrollPosition, animated: animated)
    }
    
    
    /// 计算单元格文本内容宽度
    ///
    /// - Parameter title: <#title description#>
    /// - Returns: <#return value description#>
    public func cellWidth(forTitle title: String?) -> CGFloat {
        
        guard let temTitle = title else {
            return CGSize.zero.width
        }
        
        let frame = (temTitle as NSString).boundingRect(with: CGSize(width: 1000, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], attributes: [NSAttributedString.Key.font: self.layout.selectedTextFont], context: nil)
        return CGSize(width: ceil(frame.width), height: ceil(frame.size.height) + 1).width
    }
    
    /// Cell布局
    ///
    /// - Parameter index: <#index description#>
    /// - Returns: <#return value description#>
    public func cellFrame(with index: Int) -> CGRect {
        
        guard index < self.countOfItems,
              let cellAttrs = self.collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) else {
            return CGRect.zero
        }
        
        return cellAttrs.frame
    }
    
    /// cell索引
    ///
    /// - Parameter index: index
    /// - Returns: <#return value description#>
    public func cell(for index: Int) -> TabPagerCellProtocol? {
        
        if index >= self.countOfItems {
            return nil
        }
        
        return self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? TabPagerCellProtocol
    }
}


// MARK: - private func
extension TabPagerBar {
    
    private func transition(from fromIndex: Int, to toIndex: Int, animated: Bool) {
        
        let fromCell = self.cell(for: fromIndex)
        let toCell = self.cell(for: toIndex)
        
        if self.delegate?.responds(to: #selector(self.delegate?.pagerTabBar(_:transitionFromeCell:toCell:animated:))) ?? false {
            self.delegate!.pagerTabBar!(self, transitionFromeCell: fromCell, toCell: toCell, animated: animated)
        } else {
            self.layout.transition(fromCell: fromCell, toCell: toCell, animate: animated)
        }
        self.layout.setUnderLineFrameWith(toIndex, animated: fromCell != nil && animated ? animated: false)
    }
    
    private func transition(from fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        
        let fromCell = self.cell(for: fromIndex)
        let toCell = self.cell(for: toIndex)
        
        if self.delegate?.responds(to: #selector(self.delegate?.pagerTabBar(_:transitionFromeCell:toCell:progress:))) ?? false {
            self.delegate!.pagerTabBar!(self, transitionFromeCell: fromCell, toCell: toCell, progress: progress)
        } else {
            self.layout.transition(fromCell: fromCell, toCell: toCell, progress: progress)
        }
        self.layout.setUnderLineFrameWithfromIndex(fromIndex, to: toIndex, progress: progress)
    }
}



// MARK: - UICollectionViewDataSource
extension TabPagerBar: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let temDataSource = self.dataSource else {
            Swift.fatalError("数据源协议必须实现", file: #file, line: #line)
        }
        
        self.countOfItems = temDataSource.numberOfItemsInPagerTabBar()
        return self.countOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.dataSource!.pagerTabBar(self, cellForItemAt: indexPath.item)
        self.layout.transition(fromCell: indexPath.item == self.curIndex ? nil : cell, toCell: indexPath.item == self.curIndex ? cell : nil, animate: false)
        return cell
    }
}



// MARK: - UICollectionViewDelegate
extension TabPagerBar: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.pagerTabBar?(self, didSelectItemAt: indexPath.item)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TabPagerBar: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.layout.cellWidth > 0 {
            return CGSize(width: self.layout.cellWidth + self.layout.cellEdging*2, height: self.collectionView.frame.height)
        } else if self.delegate?.responds(to: #selector(self.delegate?.pagerTabBar(_:widthForItemAt:))) ?? false {
            let width = self.delegate!.pagerTabBar!(self, widthForItemAt: indexPath.item)
            return CGSize(width: width, height: self.collectionView.frame.height)
        } else {
             Swift.fatalError("请设置Cell宽度", file: #file, line: #line)
        }
        return CGSize.zero
    }
}
