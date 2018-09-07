//
//  DMPagerView.swift
//  DMPagerView
//
//  Created by Dominic Miller on 9/6/18.
//  Copyright © 2018 Dominic Miller. All rights reserved.
//

import UIKit
import ObjectiveC

/**
 A DMPagerView lets the user navigate between pages of content.
 Navigation can be controlled programmatically by your app or directly by the user using gestures.
 */
public class DMPagerView: UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    /*
     *  MARK: - Instance Properties
     */
    
    var pages = [Int : UIView]()
    
    var registration = [String:Any]()
    var reuseQueue = [UIView]()
    
    var index: Int = 0
    var count: Int = 0
    
    var forwarder = DMPagerViewDelegateForwarder()
    
    // Delegate instance that adopt the DMPagerViewDelegate.
    @IBOutlet public dynamic weak var _delegate: DMPagerViewDelegate? {
        get { return forwarder.delegate }
        set { delegate = newValue }
    }
    @objc override public dynamic weak var delegate: UIScrollViewDelegate? {
        get { return forwarder.delegate }
        set {
            let delegate = newValue as? DMPagerViewDelegate
            guard newValue == nil || delegate != nil else { return }
            super.delegate = nil
            forwarder.delegate = delegate
            super.delegate = forwarder
        }
    }
    
    /// Data source instance that adopt the DMPagerViewDataSource.
    @IBOutlet public weak var dataSource: DMPagerViewDataSource?
    
    public var selectedPage: UIView? {
        return page(at: index)
    }

    public var indexForSelectedPage: Int {
        return index
    }

    public var transitionStyle: DMPagerViewTransitionStyle = .scroll {
        didSet { isScrollEnabled = (transitionStyle != .tab) }
    }

    public var gutterWidth: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    /// The pager progress, from 0 to the number of page.
    public var progress: CGFloat {
        let position = contentOffset.x
        let width = bounds.width
        if width == 0 { return 0 }
        return position / width
    }
    
    /*
     *  MARK: - View Life Cycle
     */
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    private func initialize() {
        forwarder.pagerView = self
        super.delegate = forwarder
        isPagingEnabled = true
        scrollsToTop = false
        isDirectionalLockEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    /*
     *  MARK: - View Life Cycle
     */
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if count <= 0 { reloadData() }
        
        var size = bounds.size
        size.width = size.width * CGFloat(count)
        
        if size.equalTo(contentSize) {
            contentSize = size
            
            let x = bounds.size.width * CGFloat(index)
            super.setContentOffset(CGPoint(x: x, y: 0), animated: false)
            
            layoutLoadedPages()
        }
    }
    
    private func layoutLoadedPages() {
        var frame: CGRect = .zero
        frame.size = bounds.size
        for (index, page) in pages {
            frame.origin.x = frame.size.width * CGFloat(index)
            page.frame = frame
        }
    }
    
    /// Reloads everything from scratch. redisplays pages.
    public func reloadData() {
        for (_, page) in pages { page.removeFromSuperview() }
        pages.removeAll()
        
        count = dataSource?.numberOfPages(in: self) ?? 0
        if count > 0 {
            index = min(index, count - 1)
            loadPage(at: index)
            setNeedsLayout()
        }
    }
    
    /// Shows through the pager until a page identified by index is at a particular location on the screen.
    ///
    /// - Parameters:
    ///   - index: An index that identifies a page.
    ///   - animated: A flag indicating whether or not you want to animate the change in position.
    ///
    /// - Note: The `animated` parameter has no effect on pager with `transitionStyle` of `.tab`.
    public func showPage(at index: Int, animated: Bool) {
        var animated = animated
        guard index >= 0 && index < count && index != self.index else { return }
        self.index = index
        
        if transitionStyle == .tab { animated = false }
        
        let x = bounds.size.width * CGFloat(index)
        setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    /// Gets a page at specific index.
    ///
    /// - Parameter index: Index representing page
    /// - Returns: The page at a given index. If the page is not loaded or `index` is out of range, returns `nil`
    public func page(at index: Int) -> UIView? {
        return pages[index]
    }
    
    // MARK: - Reusable Pages
    
    /// Registers a nib object containing a page with the pager view under a specified identifier.
    ///
    /// Before dequeueing any pages, call this method or the ```registerClass:forPageReuseIdentifier:```
    /// method to tell the pager view how to create new pages. If a page of the specified type is not currently in a
    /// reuse queue, the pager view uses the provided information to create a new page object automatically.
    ///
    /// If you previously registered a class or nib file with the same reuse identifier, the nib you specify in the
    /// `nib` parameter replaces the old entry. You may specify nil for nib if you want to unregister the nib from the
    /// specified reuse identifier.
    ///
    /// - Parameters:
    ///   - nib: A nib object that specifies the nib file to use to create the page.
    ///   - identifier: The reuse identifier for the page. This parameter must not be an empty string.
    public func register(_ nib: UINib, forPageReuseIdentifier identifier: String) {
        guard !identifier.isEmpty else { return }
        registration[identifier] = nib
    }
    
    /// Registers a class for use in creating new page.
    ///
    /// Prior to dequeueing any pages, call this method or the `registerNib:forPageReuseIdentifier:` method to tell the
    /// pager view how to create new pages. If a page of the specified type is not currently in a reuse queue, the pager
    /// view uses the provided information to create a new page object automatically.
    ///
    /// If you previously registered a class or nib file with the same reuse identifier, the class you specify in the
    /// pageClass parameter replaces the old entry. You may specify nil for pageClass if you want to unregister the
    /// class from the specified reuse identifier.
    ///
    /// - Parameters:
    ///   - pageClass: The class of a page that you want to use in the pager.
    ///   - identifier: The reuse identifier for the page. This parameter must not be an empty string.
    public func register(_ pageClass: AnyClass, forPageReuseIdentifier identifier: String) {
        guard !identifier.isEmpty else { return }
        registration[identifier] = NSStringFromClass(pageClass)
    }
    
    /// Returns a reusable page object located by its identifier.
    ///
    /// A pager view maintains a queue or list of page objects that the data source has marked for reuse. Call this
    /// method from your data source object when asked to provide a new page for the pager view. This method dequeues an
    /// existing page if one is available or creates a new one using the class or nib file you previously registered.
    /// If no page is available for reuse and you did not register a class or nib file, this method returns nil.
    ///
    /// - Parameter identifier: A string identifying the page object to be reused. This parameter must not be nil
    /// - Returns: A page object with the associated identifier. If no such object exists in the queue, returns nil.
    public func dequeueReusablePage(withIdentifier identifier: String) -> UIView? {
        if let page = dequeueFromReuseQueue(with: identifier) {
            return page
        }
        if let page = dequeueFromRegistration(with: identifier) {
            objc_setAssociatedObject(page, UIView.Keys.ReuseIdentifier, identifier, .OBJC_ASSOCIATION_COPY)
            return page
        }
        return nil
    }
    
    private func dequeueFromReuseQueue(with identifier: String) -> UIView? {
        for (idx, reuse) in reuseQueue.enumerated() {
            guard reuse.reuseIdentifier == identifier else { continue }
            reuseQueue.remove(at: idx)
            reuse.prepareForReuse()
            return reuse
        }
        return nil
    }
    
    private func dequeueFromRegistration(with identifier: String) -> UIView? {
        let builder = registration[identifier]
        let message = "Unable to dequeue a page with identifier \(identifier) - must register a nib or a class."
        assert(builder != nil, message)
        
        if let builder = builder as? UINib {
            return builder.instantiate(withOwner: nil, options: nil).first as? UIView
        }
        if let builder = builder as? String {
            return (NSClassFromString(builder) as? UIView.Type)?.init()
        }
        return nil
    }
    
    /*
     *  MARK: - Private Methods
     */
    
    private func willMovePage(to index: Int) {
        loadPage(at: index)
        
        let selector =  #selector(DMPagerViewDelegate.pagerView(_:willMoveToPage:at:))
        if objectRespondsToSelector(_delegate, selector: selector) {
            let page = pages[index]!
            _delegate!.pagerView!(self, willMoveToPage: page, at: index)
        }
    }
    
    private func didMovePage(to index: Int) {
        let selector =  #selector(DMPagerViewDelegate.pagerView(_:didMoveToPage:at:))
        if objectRespondsToSelector(_delegate, selector: selector) {
            let page = pages[index]!
            _delegate!.pagerView!(self, didMoveToPage: page, at: index)
        }
        unloadHiddenPages()
    }
    
    private func loadPage(at index: Int) {
        guard let dataSource = dataSource else { return }
        if page(at: index) == nil && index >= 0 && index < count {
            let page = dataSource.pagerView(self, viewForPageAt: index)
            
            //Layout page
            var frame: CGRect = .zero
            frame.size = bounds.size
            frame.origin = CGPoint(x: frame.width * CGFloat(index), y: 0)
            page.frame = frame
            
            let selector =  #selector(DMPagerViewDelegate.pagerView(_:willDisplayPage:at:))
            if objectRespondsToSelector(_delegate, selector: selector) {
                _delegate!.pagerView!(self, willDisplayPage: page, at: index)
            }
            
            addSubview(page)
            setNeedsLayout()
            
            //Save page
            pages[index] = page
        }
        
        //In  case of slide behavior, its loads the neighbors as well.
        if transitionStyle == .scroll {
            loadPage(at: index - 1)
            loadPage(at: index + 1)
        }
    }
            
    private func unloadHiddenPages() {
        var toUnload = [Int]()
        
        for (index, page) in pages {
            guard index != self.index else { continue }
            //In case if slide behavior, it keeps the neighbors, otherwise it unloads all hidden pages.
            if transitionStyle == .tab || (index != self.index - 1 && index != self.index + 1) {
                page.removeFromSuperview()
                toUnload.append(index)
                
                if page.reuseIdentifier != nil { reuseQueue.append(page) }
                
                let selector =  #selector(DMPagerViewDelegate.pagerView(_:didEndDisplayingPage:at:))
                if objectRespondsToSelector(_delegate, selector: selector) {
                    _delegate!.pagerView!(self, didEndDisplayingPage: page, at: index)
                }
            }
        }
        pages.removeValues(forKeys: toUnload)
    }
    
    open override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if fmod(contentOffset.x, bounds.width) == 0 {
            let index = Int(contentOffset.x / bounds.width)
            
            willMovePage(to: index)
            super.setContentOffset(contentOffset, animated: animated)
            
            self.index = index
            
            if !animated { didMovePage(to: index) }
            
        } else {
            super.setContentOffset(contentOffset, animated: animated)
        }
    }
    
    /*
     *  MARK: - UIScrollViewDelegate
     */
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.index = index
        didMovePage(to: index)
        
        let selector = #selector(DMPagerViewDelegate.scrollViewDidEndDecelerating(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidEndDecelerating!(scrollView)
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let position  = targetContentOffset.pointee.x
        let width     = scrollView.bounds.width
        
        let index = Int(position / width)
        willMovePage(to: index)
        
        let selector = #selector(DMPagerViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:))
        if objectRespondsToSelector(delegate, selector: selector){
            delegate!.scrollViewWillEndDragging!(scrollView,
                                                 withVelocity: velocity,
                                                 targetContentOffset: targetContentOffset)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didMovePage(to: index)
        let selector = #selector(DMPagerViewDelegate.scrollViewDidEndScrollingAnimation(_:))
        if objectRespondsToSelector(delegate, selector: selector) {
            delegate!.scrollViewDidEndScrollingAnimation!(scrollView)
        }
    }
    
    /*
     *  MARK: - UIGestureRecognizerDelegate
     */

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = gestureRecognizer.velocity(in: self)
        return !(fabs(velocity.x) < fabs(velocity.y))
    }

}
