//
//  CarouselView.swift
//
//  Created by Jared Sorge on 1/11/17.
//

import UIKit

public protocol CarouselViewDelegate: class {
    func didMove(to index: Int, in carouselView: CarouselView)
}

public protocol CarouselTile {
    func generateView() -> UIView
}

/// This class presents a series of tiles that can scroll horizontally. Optionally the scroll view can scroll its contents infinitely as well
/// Tiles will span the full height of the scroll view
open class CarouselView: UIView, UIScrollViewDelegate {
    public enum TilePinLocation {
        case left, right, center
    }
    
    /// Used to configure behavior for how inactive tiles (those not currently in the scroll view's bounds) should appear
    ///
    /// - dim: If they should dim, then the number here is the new alpha value
    /// - doNotDim: Used if they should not dim
    public enum InactiveTileConfig {
        case dim(CGFloat)
        case doNotDim
    }
    
    fileprivate class _Tile: Equatable {
        let tile: CarouselTile
        var view: UIView?
        var associatedViews = [UIView]()
        
        init(tile: CarouselTile, view: UIView?) {
            self.tile = tile
            self.view = view
        }
        
        func vendExtraView() -> UIView {
            let newView = tile.generateView()
            newView.alpha = view?.alpha ?? 1.0
            associatedViews.append(newView)
            return newView
        }
        
        func applyAlpha(_ alpha: CGFloat) {
            view?.alpha = alpha
            for view in associatedViews {
                view.alpha = alpha
            }
        }
        
        func containsView(_ view: UIView) -> Bool {
            if self.view == view {
                return true
            }
            
            for vendedView in associatedViews {
                if vendedView == view {
                    return true
                }
            }
            
            return false
        }
        
        private let _uuid = UUID()
        static func ==(lhs: _Tile, rhs: _Tile) -> Bool {
            return lhs._uuid == rhs._uuid
        }
    }
    
    // MARK: - API
    public weak var delegate: CarouselViewDelegate?
    
    public final let pageControl: UIPageControl = {
        let control = UIPageControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    public var pinLocation: TilePinLocation = .center {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    public var horizontalPadding: CGFloat = 0.0 {
        didSet {
            updateScrollview()
        }
    }
    
    public var tileSize: CGSize = .zero {
        didSet {
            setNeedsUpdateConstraints()
            updateScrollview()
            layoutIfNeeded()
        }
    }
    
    private var _showPageControl = true
    public var isPageControlVisible: Bool {
        get {
            return _showPageControl && _tiles.count > 1
        }
        set {
            _showPageControl = newValue
        }
    }
    
    open var isInifiniteScrolling: Bool = false
    open var inactiveTileConfig: InactiveTileConfig = .doNotDim
    
    public var currentView: UIView? {
        return _tiles[currentIndex].view
    }
    
    public var currentIndex: Int {
        return pageControl.currentPage
    }
    
    public final func display(_ tiles: [CarouselTile]) {
        _adjustedTiles.forEach { $0.removeFromSuperview() }
        _tiles = tiles.map { _Tile(tile: $0, view: nil) }
        recalculateViews()
    }
    
    public final func appendTile(_ tile: CarouselTile) {
        _tiles.append(_Tile(tile: tile, view: nil))
        recalculateViews()
    }
    
    public final func insertTile(_ tile: CarouselTile, at index: Int) {
        _tiles.insert(_Tile(tile: tile, view: nil), at: index)
        recalculateViews()
    }
    
    private var _currentlyScrolling = false
    public final func scrollToItem(atIndex index: Int, animated: Bool = true) {
        // Figure out the view that needs to be displayed (from the _adjustedTiles array)
        let viewToDisplay: UIView
        if isInifiniteScrolling && _tiles.count > 1 {
            if index == -1 {
                // The back button was pressed when on the first tile
                viewToDisplay = _adjustedTiles[1]
            }
            else if index == _tiles.count {
                // The forward button was pressed when on the last tile
                viewToDisplay = _adjustedTiles[_adjustedTiles.count - 2]
            }
            else {
                let viewIndex = index + 2 // need to add a buffer on account of the first 2 views prepended
                viewToDisplay = _adjustedTiles[viewIndex]
            }
        }
        else {
            guard index >= 0,
                index < _adjustedTiles.count
                else { return }
            viewToDisplay = _adjustedTiles[index]
        }
        
        // Figure out the tile that it belongs to
        guard let tile = _tiles.filter({ $0.containsView(viewToDisplay) }).first,
            let tileIndex = _tiles.index(of: tile)
            else { return }
        
        // Scroll to the view
        if _currentlyScrolling == false && animated {
            self._currentlyScrolling = true
            UIView.animate(withDuration: 0.2, animations: {
                self._scrollView.setContentOffset(viewToDisplay.frame.origin, animated: false)
            }, completion: { _ in
                self._currentlyScrolling = false
            })
        }
        else {
            _scrollView.setContentOffset(viewToDisplay.frame.origin, animated: false)
        }
        
        // If the view is outside of the bounds of the _tiles array, scroll to the proper item in the tiles array without animation
        if index < 0 || index >= _tiles.count,
            let tileMainView = tile.view {
            _scrollView.setContentOffset(tileMainView.frame.origin, animated: false)
        }
        
        
        // Apply inactive tile state if needed
        if case InactiveTileConfig.dim(let alpha) = inactiveTileConfig {
            UIView.animate(withDuration: 0.2) {
                for (tileIndex, tile) in self._tiles.enumerated() {
                    if index == tileIndex {
                        tile.applyAlpha(1.0)
                    }
                    else {
                        tile.applyAlpha(alpha)
                    }
                }
            }
        }
        
        // Update the page control and call the delegate
        guard tileIndex != pageControl.currentPage else { return }
        pageControl.currentPage = index
        delegate?.didMove(to: tileIndex, in: self)
    }
    
    public final func scrollToNextTile(animated: Bool = true) {
        let nextIndex = (currentIndex + 1) % _tiles.count
        scrollToItem(atIndex: nextIndex, animated: animated)
    }
    
    public final func scrollToPreviousTile(animated: Bool = true) {
        let nextIndex: Int
        if currentIndex == 0 {
            nextIndex = _tiles.count - 1
        }
        else {
            nextIndex = currentIndex - 1
        }
        scrollToItem(atIndex: nextIndex, animated: animated)
    }
    
    // MARK: - Override
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open override func updateConstraints() {
        // Constraints applied to self
        removeConstraints(_viewContstraints)
        _viewContstraints.removeAll()
        
        let xConstraint: NSLayoutConstraint
        switch pinLocation {
        case .center:
            xConstraint = NSLayoutConstraint(item: _scrollView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        case .left:
            xConstraint = NSLayoutConstraint(item: _scrollView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
        case .right:
            xConstraint = NSLayoutConstraint(item: _scrollView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
        }
        _viewContstraints.append(xConstraint)
        
        
        let heightConstraint = NSLayoutConstraint(item: _scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tileSize.height)
        let widthConstraint = NSLayoutConstraint(item: _scrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tileSize.width + horizontalPadding * 2)
        let centerYConstraint = NSLayoutConstraint(item: _scrollView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        _viewContstraints.append(contentsOf: [heightConstraint, widthConstraint, centerYConstraint])
        
        if _showPageControl {
            let hConstraint = NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -8.0)
            _viewContstraints.append(contentsOf: [hConstraint, bottomConstraint])
        }
        
        _viewContstraints.forEach { $0.isActive = true }
        addConstraints(_viewContstraints)
        super.updateConstraints()
    }

    // MARK: - UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let visibleView = viewForContentOffset(scrollView.contentOffset, in: scrollView),
            let tile = _tiles.filter({ $0.containsView(visibleView) }).first,
            let tileIndex = _tiles.index(of: tile)
            else { return }
        
        scrollToItem(atIndex: tileIndex, animated: false)
    }

    // MARK: - Private
    /// Constraints applied to the scroll view to manage its content
    private var _scrollViewconstraints = [NSLayoutConstraint]()
    /// Constraints applied to the Carousel view
    private var _viewContstraints = [NSLayoutConstraint]()
    /// These are the tiles the view is being asked to displayed
    private var _tiles = [_Tile]()
    /// These are the views being displayed. If the carousel is infinitely scrolling, then this will have redundant views inside of it
    private var _adjustedTiles = [UIView]()
    
    internal let _scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        view.isPagingEnabled = true
        view.backgroundColor = .clear
        return view
    }()
    
    private func commonInit() {
        clipsToBounds = true
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        addSubview(_scrollView)
        _scrollView.delegate = self
        addGestureRecognizer(_scrollView.panGestureRecognizer)
        addSubview(pageControl)
        bringSubviewToFront(pageControl)
    }
    
    private var _extraTiles = [UIView]()
    private func recalculateViews() {
        defer {
            pageControl.numberOfPages = _tiles.count
            pageControl.isHidden = _tiles.count == 1
            updateScrollview()
        }
        
        _extraTiles.forEach { $0.removeFromSuperview() }
        _extraTiles.removeAll()
        
        _adjustedTiles.forEach { $0.removeFromSuperview() }
        _adjustedTiles.removeAll()
        
        for (index, tile) in _tiles.enumerated() {
            let view = tile.tile.generateView()
            if case InactiveTileConfig.dim(let alpha) = inactiveTileConfig {
                view.alpha = alpha
            }
            let newTile = _Tile(tile: tile.tile, view: view)
            _tiles[index] = newTile
            _adjustedTiles.append(view)
        }
        
        guard _tiles.count > 1, isInifiniteScrolling else {
            return
        }
        
        let firstCopy = _tiles.first!.vendExtraView()
        _adjustedTiles.append(firstCopy)
        _extraTiles.append(firstCopy)
        let lastCopy = _tiles.last!.vendExtraView()
        _adjustedTiles.insert(lastCopy, at: 0)
        _extraTiles.append(lastCopy)
        
        let secondCopy = _tiles[1].vendExtraView()
        _adjustedTiles.append(secondCopy)
        _extraTiles.append(secondCopy)
        let penultimateCopy = _tiles[_tiles.count - 2].vendExtraView()
        _adjustedTiles.insert(penultimateCopy, at: 0)
        _extraTiles.append(penultimateCopy)
    }
    
    private func updateScrollview() {
        _scrollView.removeConstraints(_scrollViewconstraints)
        _scrollViewconstraints.removeAll()
        
        guard _adjustedTiles.count > 0 else { return }
        
        // Constraints applied to the scroll view
        var views = [String: UIView]()
        let interItemPadding = horizontalPadding * 2
        let metrics = ["edge": horizontalPadding, "interItem": interItemPadding, "width": tileSize.width]
        var horizontalConstraintString = "|-(edge)-"
        var newConstraints = [NSLayoutConstraint]()
        for (index, tile) in _adjustedTiles.enumerated() {
            _scrollView.addSubview(tile)
            tile.translatesAutoresizingMaskIntoConstraints = false
            
            let viewKey = "view\(index)"
            views[viewKey] = tile
            
            if index != 0 {
                horizontalConstraintString += "-(interItem)-"
            }
            else {
                let heightViews = ["view": tile]
                let heightMetrics = ["height": tileSize.height]
                let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view(height)]|", options: [], metrics: heightMetrics, views: heightViews)
                newConstraints.append(contentsOf: heightConstraints)
                let centerYConstraint = NSLayoutConstraint(item: _scrollView, attribute: .centerY, relatedBy: .equal, toItem: tile, attribute: .centerY, multiplier: 1.0, constant: 0)
                newConstraints.append(centerYConstraint)
            }
            
            horizontalConstraintString += "[\(viewKey)(width)]"
        }
        
        horizontalConstraintString += "-(edge)-|"
        
        let contentHorizontal = NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraintString, options: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views)
        newConstraints = [newConstraints + contentHorizontal].flatMap { $0 }
        newConstraints.forEach { $0.isActive = true }
        _scrollViewconstraints = newConstraints
        
        _scrollView.addConstraints(_scrollViewconstraints)
        setNeedsLayout()
        setNeedsUpdateConstraints()
        layoutIfNeeded()
        
        scrollToItem(atIndex: pageControl.currentPage, animated: false)
    }
    
    private func viewForContentOffset(_ offset: CGPoint, in scrollView: UIScrollView) -> UIView? {
        for tile in _adjustedTiles {
            if ceil(scrollView.convert(offset, to: tile).x) + floor(horizontalPadding) == 0 {
                return tile
            }
        }
        
        return nil
    }
}

