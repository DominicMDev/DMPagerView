//
//  Extensions.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit

extension Dictionary {
    mutating func removeValues(forKeys keys: [Key]) {
        for key in keys {
            removeValue(forKey: key)
        }
    }
}

public extension UIView {
    
    internal struct Keys {
        static var ReuseIdentifier = "dm_ReuseIdentifier"
    }
    
    public convenience init(reuseIdentifier: String) {
        self.init()
        objc_setAssociatedObject(self, Keys.ReuseIdentifier, reuseIdentifier, .OBJC_ASSOCIATION_COPY)
    }
    
    public convenience init(frame: CGRect, reuseIdentifier: String) {
        self.init(frame: frame)
        objc_setAssociatedObject(self, Keys.ReuseIdentifier, reuseIdentifier, .OBJC_ASSOCIATION_COPY)
    }
    
    public convenience init?(coder aDecoder: NSCoder, reuseIdentifier: String) {
        self.init(coder: aDecoder)
        objc_setAssociatedObject(self, Keys.ReuseIdentifier, reuseIdentifier, .OBJC_ASSOCIATION_COPY)
    }
    
    @objc public var reuseIdentifier: String? {
        return objc_getAssociatedObject(self, Keys.ReuseIdentifier) as? String
    }
    
    @objc public func prepareForReuse() {}
    
}
