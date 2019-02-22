//
//  MemoryCache.swift
//  XBPagerController
//
//  Created by xiaobin liu on 2019/2/22.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Foundation


/// MARK - 内存缓存
open class MemoryCache: NSCache<AnyObject, AnyObject> {
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeAllObjects),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didReceiveMemoryWarningNotification,
                                                  object: nil)
    }
}
