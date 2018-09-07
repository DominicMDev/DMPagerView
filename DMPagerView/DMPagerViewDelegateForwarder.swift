//
//  DMPagerViewDelegateForwarder.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

class DMPagerViewDelegateForwarder: NSObject, UIScrollViewDelegate {
    weak var pagerView: DMPagerView?
    weak var delegate: DMPagerViewDelegate?

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if objectRespondsToSelector(pagerView, selector: aSelector) { return pagerView }
        if objectRespondsToSelector(delegate, selector: aSelector) { return delegate }
        return super.forwardingTarget(for: aSelector)
    }

    override func responds(to aSelector: Selector!) -> Bool {
        return objectRespondsToSelector(pagerView, selector: aSelector) ||
            objectRespondsToSelector(delegate, selector: aSelector) ||
            super.responds(to: aSelector)
    }

}

extension NSObjectProtocol {
    func objectRespondsToSelector(_ object: NSObjectProtocol?, selector: Selector) -> Bool {
        guard let _object = object else { return false }
        return _object.responds(to: selector)
    }
}
