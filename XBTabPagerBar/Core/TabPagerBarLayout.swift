//
//  XBTabPagerBarLayout.swift
//  XBTabPagerBar
//
//  Created by xiaobin liu on 2019/2/14.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit

/// MARK - 样式
///
/// - none: 无
/// - progress: 进度样式
/// - progressBounce: 进度反弹
/// - progressElastic: 进度弹性
/// - cover: 封面
public enum PagerBarStyle: Int {
    case none
    case progress
    case progressBounce
    case progressElastic
    case cover
}

/// MARK - TabPagerBarLayout
public class TabPagerBarLayout: NSObject {
    
    /// barStyle 默认progressElastic
    public var barStyle: PagerBarStyle = PagerBarStyle.progressElastic {
        didSet {
            
            if barStyle == oldValue {
                return
            }
            
            if barStyle == .cover {
                self.progressBorderWidth = 0
                self.progressBorderColor = nil
            }
            
            switch barStyle {
            case .progress:
                self.progressWidth = 0
                self.progressHorEdging = 6
                self.progressVerEdging = 0
                self.progressHeight = 2
            case .progressBounce, .progressElastic:
                self.progressWidth = 30
                self.progressVerEdging = 0
                self.progressHorEdging = 0
                self.progressHeight = 2
            case .cover:
                self.progressWidth = 0
                self.progressHorEdging = -self.progressHeight/4
                self.progressVerEdging = 3
            default:
                break
            }
            
            self.pagerTabBar.progressView.isHidden = barStyle == .none
            if barStyle == .cover {
                self.progressRadius = 0
                self.pagerTabBar.progressView.layer.zPosition = -1
                self.pagerTabBar.progressView.removeFromSuperview()
                self.pagerTabBar.collectionView.insertSubview(self.pagerTabBar.progressView, at: 0)
            } else {
                self.progressRadius = self.progressHeight/2
                if self.pagerTabBar.progressView.layer.zPosition == -1 {
                    self.pagerTabBar.progressView.layer.zPosition = 0
                    self.pagerTabBar.progressView.removeFromSuperview()
                    self.pagerTabBar.collectionView.addSubview(self.pagerTabBar.progressView)
                }
            }
        }
    }
    
    /// sectionInset
    private var _sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    public var sectionInset: UIEdgeInsets {
        
        get {
            
            if !(_sectionInset == .zero) || self.barStyle != .cover {
                return _sectionInset
            }
            
            if self.barStyle == .cover && self.adjustContentCellsCenter {
                return _sectionInset
            }
            
            let horEdging: CGFloat = -progressHorEdging + cellSpacing
            return UIEdgeInsets(top: 0, left: horEdging, bottom: 0, right: horEdging)
        }
        set {
            _sectionInset = newValue
        }
    }
    
    /// progress view
    /// 进度条高度
    public var progressHeight: CGFloat = 2 {
        didSet {
            
            var frame = self.pagerTabBar.progressView.frame
            let height = self.pagerTabBar.collectionView.bounds.height
            frame.origin.y = self.barStyle == .cover ? (height - self.progressHeight)/2 : (height - self.progressHeight - self.progressVerEdging)
            frame.size.height = progressHeight
            self.pagerTabBar.progressView.frame = frame
        }
    }
    
    /// 进度条宽度
    public var progressWidth: CGFloat = 0
    
    /// 进度条颜色
    public var progressColor: UIColor = UIColor.clear {
        didSet {
            self.pagerTabBar.progressView.backgroundColor = progressColor
        }
    }
    
    /// 进度条半径
    public var progressRadius: CGFloat = 0 {
        didSet {
           self.pagerTabBar.progressView.layer.cornerRadius = progressRadius
        }
    }
    
    /// 进度条边框宽度
    public var progressBorderWidth: CGFloat = 0 {
        didSet {
            self.pagerTabBar.progressView.layer.borderWidth = progressBorderWidth
        }
    }
    
    /// 进度条边框颜色
    public var progressBorderColor: UIColor? {
        didSet {
            if self.progressColor == UIColor.clear {
                self.pagerTabBar.progressView.backgroundColor = UIColor.clear
            }
            self.pagerTabBar.progressView.layer.borderColor = progressBorderColor?.cgColor
        }
    }
    
    /// 进度条水平边距
    public var progressHorEdging: CGFloat = 6
    
    /// 进度条垂直边距
    public var progressVerEdging: CGFloat = 0
    
    
    /// cell frame
    /// 单元格宽度
    public var cellWidth: CGFloat = 0
    
    /// 单元格间距
    public var cellSpacing: CGFloat = 2
    
    /// 单元格左右边距
    public var cellEdging: CGFloat = 3
    
    /// 默认false,单元格中心如果contentSize < bar的宽度，将设置sectionInset
    public var adjustContentCellsCenter: Bool = false {
        didSet {
            
            let change = adjustContentCellsCenter != oldValue
            if change && self.pagerTabBar.superview != nil {
                self.pagerTabBar.setNeedsLayout()
            }
        }
    }
    
    
    // TabPagerBarCellProtocol -> cell's label
    
    /// 默认文本字体
    public var normalTextFont: UIFont = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
    
    /// 选中文本字体
    public var selectedTextFont: UIFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
    
    /// 默认文本颜色
    public var normalTextColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    
    /// 选中文本颜色
    public var selectedTextColor: UIColor = UIColor.red
    
    /// 文本颜色进度是否启用(默认为true)
    public var textColorProgressEnable: Bool = true
    
    /// 动画时间
    public var animateDuration: Double = 0.25
    
    /// pagerTabBar
    private weak var pagerTabBar: TabPagerBar!
    
    /// selectFontScale
    private(set) var selectFontScale: CGFloat = 0
    
    
    /// 初始化
    ///
    /// - Parameter pagerTabBar: <#pagerTabBar description#>
    public init(pagerTabBar: TabPagerBar) {
        super.init()
        self.pagerTabBar = pagerTabBar
        self.barStyle = .progressElastic
    }
    
    
    /// 单元格布局
    ///
    /// - Parameter index: 索引
    /// - Returns: CGRect
    private func cellFrame(with index: Int) -> CGRect {
        return pagerTabBar.cellFrame(with: index)
    }
}


// MARK: - public func
extension TabPagerBarLayout {
    
    
    /// 立即执行刷行布局
    public func layoutIfNeed() {
        
        let collectionLayout = self.pagerTabBar.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionLayout.minimumLineSpacing = self.cellSpacing
        collectionLayout.minimumInteritemSpacing = self.cellSpacing
        self.selectFontScale = self.normalTextFont.pointSize/self.selectedTextFont.pointSize
        collectionLayout.sectionInset = self.sectionInset
    }
    
    
    /// 无效的布局
    public func invalidateLayout() {
        self.pagerTabBar.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    /// 布局视图
    public func layoutSubViews() {
        
        if self.pagerTabBar.frame.isEmpty {
            return
        }
        
        if barStyle == .cover {
             self.progressHeight = self.pagerTabBar.collectionView.frame.height - self.progressVerEdging * 2
             self.progressRadius = self.progressRadius > 0 ? self.progressRadius : self.progressHeight / 2
        }
        self.setUnderLineFrameWith(self.pagerTabBar.curIndex, animated: false)
    }
    
    /// 调整内容单元格在栏中的中心位置
    public func adjustContentCellsCenterInBar() {
        
        if adjustContentCellsCenter == false || self.pagerTabBar.superview == nil {
            return
        }
        
        let frame = self.pagerTabBar.collectionView.frame
        if frame.isEmpty {
            return
        }
        
        let collectionLayout = self.pagerTabBar.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let contentSize = collectionLayout.collectionViewContentSize
        guard let layoutAttribulte = collectionLayout.layoutAttributesForElements(in: CGRect(x: 0, y: 0, width: max(contentSize.width, frame.width), height: max(contentSize.height, frame.height))),
            layoutAttribulte.count == 0 else {
            return
        }
        
        let firstAttribute = layoutAttribulte.first
        let lastAttribute = layoutAttribulte.last
        let left = firstAttribute?.frame.minX ?? 0
        let right = lastAttribute?.frame.maxX ?? 0
        if right - left > self.pagerTabBar.frame.width {
           return
        }
        
        let space = (self.pagerTabBar.frame.width - (right - left))/2
        self.sectionInset = UIEdgeInsets(top: _sectionInset.top, left: space, bottom: _sectionInset.bottom, right: space)
        collectionLayout.sectionInset  = self.sectionInset
    }
    
    
    
    /// 动画过度
    ///
    /// - Parameters:
    ///   - fromCell: fromCell
    ///   - toCell: toCell
    ///   - animate: 是否动画
    public func transition(fromCell: CellProtocol?, toCell: CellProtocol?, animate: Bool) {
        
        guard self.pagerTabBar.countOfItems != 0 else {
            return
        }
        
        let animateBlock = { () -> Void in
            
            if let temFromCell = fromCell {
                temFromCell.titleLabel.font = self.normalTextFont
                temFromCell.titleLabel.textColor = self.normalTextColor
                temFromCell.transform = CGAffineTransform(scaleX: self.selectFontScale, y: self.selectFontScale)
            }
            
            if let temToCell = toCell {
                temToCell.titleLabel.font = self.normalTextFont
                temToCell.titleLabel.textColor = self.selectedTextColor
                temToCell.transform = .identity
            }
        }
        
        if animate {
            
            UIView.animate(withDuration: self.animateDuration, animations: animateBlock)
            
        } else {
            animateBlock()
        }
    }
    
    
    /// 动画过度进度
    ///
    /// - Parameters:
    ///   - fromCell: fromCell
    ///   - toCell: toCell
    ///   - progress: progress
    public func transition(fromCell: CellProtocol?, toCell: CellProtocol?, progress: CGFloat) {
        
        if self.pagerTabBar.countOfItems == 0 || self.textColorProgressEnable == false {
            return
        }
        
        let currentTransform = (1.0 - self.selectFontScale) * progress
        fromCell?.transform = CGAffineTransform(scaleX: 1.0 - currentTransform, y: 1.0 - currentTransform)
        toCell?.transform = CGAffineTransform(scaleX: selectFontScale + currentTransform, y: selectFontScale + currentTransform)
        if normalTextColor == selectedTextColor {
            return
        }
        
        var narR: CGFloat = 0, narG: CGFloat = 0, narB: CGFloat = 0, narA: CGFloat = 1
        self.normalTextColor.getRed(&narR, green: &narG, blue: &narB, alpha: &narA)

        var selR: CGFloat = 0, selG: CGFloat = 0, selB: CGFloat = 0, selA: CGFloat = 1
        self.selectedTextColor.getRed(&selR, green: &selG, blue: &selB, alpha: &selA)

        let detalR: CGFloat = narR - selR, detalG: CGFloat = narG - selG, detalB: CGFloat = narB - selB, detalA: CGFloat = narA - selA
        fromCell?.titleLabel.textColor = UIColor(red: selR + detalR * progress, green: selG + detalG * progress, blue: selB + detalB * progress, alpha: selA + detalA * progress)
        toCell?.titleLabel.textColor = UIColor(red: narR - detalR * progress, green: narG - detalG * progress, blue: narB - detalB * progress, alpha: narA - detalA * progress)
    }
    
    
    /// 设置进度视图框架
    ///
    /// - Parameters:
    ///   - index: index
    ///   - animated: animated
    public func setUnderLineFrameWith(_ index: Int, animated: Bool) {
        
        let progressView = self.pagerTabBar.progressView
        if progressView.isHidden || self.pagerTabBar.countOfItems == 0 {
            return
        }
        
        let cellFrame = self.cellFrame(with: index)
        let progressHorEdging = self.progressWidth > 0 ? (cellFrame.size.width - self.progressWidth)/2 : self.progressHorEdging
        let progressX = cellFrame.origin.x + progressHorEdging
        let progressY = self.barStyle == .cover ? (cellFrame.size.height - self.progressHeight)/2 :(cellFrame.size.height - progressHeight - progressVerEdging)
        let width = cellFrame.size.width - 2 * progressHorEdging
    
        if animated {
            UIView.animate(withDuration: animateDuration) {
                progressView.frame = CGRect(x: progressX,
                                            y: progressY,
                                            width: width,
                                            height: self.progressHeight)
            }
        } else {
            progressView.frame = CGRect(x: progressX,
                                        y: progressY,
                                        width: width,
                                        height: self.progressHeight)
        }
    }
    
    
    /// 设置进度视图框架
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - progress: progress
    public func setUnderLineFrameWithfromIndex(_ fromIndex: Int, to toIndex: Int, progress: CGFloat) {
        
        let progressView = pagerTabBar.progressView
        if progressView.isHidden || pagerTabBar.countOfItems == 0 {
            return
        }
        
        let fromCellFrame = self.cellFrame(with: fromIndex)
        let toCellFrame = self.cellFrame(with: toIndex)
        
        let progressFromEdging = progressWidth > 0 ? (fromCellFrame.size.width - progressWidth)/2 : progressHorEdging
        let progressToEdging = progressWidth > 0 ? (toCellFrame.size.width - progressWidth)/2 : progressHorEdging
        let progressY = barStyle == .cover ? (toCellFrame.size.height - progressHeight)/2 : (toCellFrame.size.height - progressHeight - progressVerEdging)
        var progressX: CGFloat = 0, width: CGFloat = 0
        
        
        switch barStyle {
        case .progressBounce:
            
            if fromCellFrame.origin.x < toCellFrame.origin.x {
                if progress <= 0.5 {
                    progressX = fromCellFrame.origin.x + progressFromEdging
                    width = (toCellFrame.size.width - progressToEdging + progressFromEdging + cellSpacing) * 2 * progress + fromCellFrame.size.width - 2 * progressFromEdging
                } else {
                    
                    progressX = fromCellFrame.origin.x + progressFromEdging + (fromCellFrame.size.width-progressFromEdging+progressToEdging + cellSpacing) * (progress - 0.5) * 2
                    width = toCellFrame.maxX - progressToEdging - progressX
                    
                }
            } else {
                
                if progress <= 0.5 {
                    
                    progressX = fromCellFrame.origin.x + progressFromEdging - (toCellFrame.size.width-progressToEdging+progressFromEdging + cellSpacing) * 2 * progress
                    width = fromCellFrame.maxX - progressFromEdging - progressX
                } else {
                    
                    progressX = toCellFrame.origin.x + progressToEdging
                    width = (fromCellFrame.size.width - progressFromEdging + progressToEdging + cellSpacing) * (1 - progress) * 2 + toCellFrame.size.width - 2 * progressToEdging
                }
            }
        case .progressElastic:
            
            if fromCellFrame.origin.x < toCellFrame.origin.x {
                    if progress <= 0.5 {
                        progressX = fromCellFrame.origin.x + progressFromEdging + (fromCellFrame.size.width - 2 * progressFromEdging) * progress
                        width = (toCellFrame.size.width - progressToEdging+progressFromEdging + cellSpacing) * 2 * progress - (toCellFrame.size.width - 2 * progressToEdging) * progress + fromCellFrame.size.width - 2 * progressFromEdging-(fromCellFrame.size.width - 2 * progressFromEdging) * progress
                    } else  {
                        progressX = fromCellFrame.origin.x + progressFromEdging + (fromCellFrame.size.width - 2 * progressFromEdging) * 0.5 + (fromCellFrame.size.width - progressFromEdging - (fromCellFrame.size.width - 2 * progressFromEdging) * 0.5 + progressToEdging + cellSpacing) * (progress - 0.5) * 2
                        width = toCellFrame.maxX - progressToEdging - progressX - (toCellFrame.size.width - 2 * progressToEdging) * (1 - progress)
                    }
            } else {
                
                if (progress <= 0.5) {
                    
                    progressX = fromCellFrame.origin.x + progressFromEdging - (toCellFrame.size.width-(toCellFrame.size.width-2*progressToEdging)/2-progressToEdging+progressFromEdging+cellSpacing)*2*progress
                    width = fromCellFrame.maxX - (fromCellFrame.size.width-2*progressFromEdging)*progress - progressFromEdging - progressX
                } else {
                    progressX = toCellFrame.origin.x + progressToEdging+(toCellFrame.size.width-2*progressToEdging)*(1-progress);
                    width = (fromCellFrame.size.width-progressFromEdging+progressToEdging-(fromCellFrame.size.width-2*progressFromEdging)/2 + cellSpacing)*(1-progress)*2 + toCellFrame.size.width - 2*progressToEdging - (toCellFrame.size.width-2*progressToEdging)*(1-progress)
                }
            }
        default:
            progressX = (toCellFrame.origin.x+progressToEdging-(fromCellFrame.origin.x+progressFromEdging))*progress+fromCellFrame.origin.x+progressFromEdging
            width = (toCellFrame.size.width-2*progressToEdging)*progress + (fromCellFrame.size.width-2*progressFromEdging)*(1-progress)
        }
        
        progressView.frame = CGRect(x: progressX,
                                    y: progressY,
                                    width: width,
                                    height: progressHeight)
    }

}

