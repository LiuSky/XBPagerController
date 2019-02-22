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
        set {
            objc_setAssociatedObject(self, &kPagerReuseIdentifyKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let value = objc_getAssociatedObject(self, &kPagerReuseIdentifyKey) as? String {
                return value
            }
            return ""
        }
    }
}
