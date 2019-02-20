//
//  NSObject+.swift
//  XBPagerController
//
//  Created by xiaobin liu on 2019/2/20.
//  Copyright © 2019 Sky. All rights reserved.
//

import Foundation


private var kPagerReuseIdentifyKey: Void?
// MARK: - Extension pagerReuseIdentifyKey
public extension NSObject {
    
    public var pagerReuseIdentifyKey: String {
        get {
            let pagerReuseIdentifyKey: String
            if let value = objc_getAssociatedObject(self, &kPagerReuseIdentifyKey) as? String {
                pagerReuseIdentifyKey = value
            } else {
                pagerReuseIdentifyKey = ""
                objc_setAssociatedObject(self, &kPagerReuseIdentifyKey, pagerReuseIdentifyKey, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return pagerReuseIdentifyKey
        }
        set {
        }
    }
}
