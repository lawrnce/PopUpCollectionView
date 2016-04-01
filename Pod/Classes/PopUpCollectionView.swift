//
//  PopUpCollectionView.swift
//  PopUpCollectionView
//
//  Created by Lawrence Tran on 3/30/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

// MARK: - DELEGATE
public protocol PopUpCollectionViewDelegate {
    
    //  Asks the delegate for the content size of the item at a given index path.
    //
    //
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    
    //  Notifies the delegate when to hide the status bar.
    //
    //
    func setStatusBarHidden(hidden: Bool)
}

// MARK: - DATA SOURCE
public protocol PopUpCollectionViewDataSource {
    
    //  Asks your data source the number of items in each section.
    //
    //
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, numberOfItemsInSection section: Int) -> Int
    
    //  Asks your data source for the content view at the given index.
    //
    //
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, contentViewAtIndexPath indexPath: NSIndexPath) -> UIView
    
    //  Asks your data source the info view for the content at a given index.
    //  Set any target selectors for your info view here.
    //
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, infoViewForItemAtIndexPath indexPath: NSIndexPath) -> UIView
}

public class PopUpCollectionView: UIView {

    // MARK: - PUBLIC VARIABLES
    
    //  Delegate
    //
    //
    public var delegate: PopUpCollectionViewDelegate?
    
    //  Data Source
    //  Pop Up Collection View receives its data just like a normal collection view.
    //
    public var dataSource: PopUpCollectionViewDataSource?
    
    
    // MARK: - PUBLIC METHODS
    
    //  Creates a PopUp Collection View with a given frame.
    //
    //
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    //  Creates a Pop Up Collection View with a Decoder.
    //  Usually via a nib file.
    //
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //  Reloads the collection view.
    //
    //
    public func reloadData() {
        self.collectionView.reloadData()
    }

    // MARK: - PRIVATE VARIABLES
    
    //  Main collection view that holds the cells. Pop Up collection view
    //  then transfers a selected cell to a detail view controller
    //  this ensures continuity if the cells are animating.
    private var collectionView: UICollectionView!
    
    //  Custom waterfall style layout. Pinterest style.
    //  Code taken from https://www.raywenderlich.com/107439/uicollectionview-custom-layout-tutorial-pinterest
    //  Modified for specific use case.
    private var pinterestLayout: PinterestLayout!
    
    //  When showing a cell's detail, detail view controller is added
    //  as a child view controller to the superview's view controller
    //
    private var detailViewController: DetailPopUpViewController!
    
    //  Determines if the Pop Up Collection View should scroll
    //  after presenting a detail cell.
    //  This ensures smooth closing animation.
    private var shouldAutoScroll: Bool = false
    
    // MARK: - PRIVATE METHODS
    
    //  Initial setup
    //
    //
    private func setup() {
        setupCollectionView()
        setupDetailViewController()
    }
    
    //  Init all nesscessary compoenents
    //
    //
    private func setupCollectionView() {
        self.pinterestLayout = PinterestLayout()
        self.pinterestLayout.delegate = self
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.pinterestLayout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.registerClass(PopUpCollectionViewCell.self, forCellWithReuseIdentifier: PopUpCollectionViewCellReuseIdentifier)
        self.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .Top, relatedBy: .Equal,
            toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .Bottom, relatedBy: .Equal,
            toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leadingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .Leading, relatedBy: .Equal,
            toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .Trailing, relatedBy: .Equal,
            toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        topConstraint.active = true
        bottomConstraint.active = true
        leadingConstraint.active = true
        trailingConstraint.active = true
        self.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    //  Init the detail view controller
    //
    //
    private func setupDetailViewController() {
        self.detailViewController = DetailPopUpViewController()
        self.detailViewController.delegate = self
        self.detailViewController.dataSource = self
        if let parent = self.parentViewController {
            parent.addChildViewController(self.detailViewController)
        }
    }
    
    //  Calculates the difference between the Pop Up Collection View's y offset
    //  and the top of the window.
    //
    private func getExpandedFrameOrigin() -> CGPoint {
        return CGPointMake(0, -self.frame.origin.y)
    }
}

extension PopUpCollectionView: PinterestLayoutDelegate {
    
    //  Asks the delegate for the content size. Then scale the content size
    //  so that the width is equal to the column size. Return the scaled height
    //  to the layout.
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth: CGFloat) -> CGFloat {
        let size = self.delegate?.popUpCollectionView(self, sizeForItemAtIndexPath: indexPath)
        return (size?.height)! * (UIScreen.mainScreen().bounds.width / 2.0) / (size?.width)!
    }
}

extension PopUpCollectionView: DetailPopUpViewControllerDatasource {
    
    //  Ask the data source for the number of items in each section
    //  for the detail view controller's collection view
    //
    func detailPopUpViewController(detailPopUpViewController: DetailPopUpViewController, numberOfItemsInSection section: Int) -> Int {
        return (dataSource?.popUpCollectionView(self, numberOfItemsInSection: section))!
    }
    
    //  Borrows the Pop Up Collection View's cell content view at a given index path
    //  and inserts it into the detail view controller's cell hierarchy.
    //  This ensures smooth transition if the cell is animating.
    func detailPopUpViewController(detailPopUpViewController: DetailPopUpViewController, contentViewAtIndexPath indexPath: NSIndexPath) -> UIView {
        if (self.shouldAutoScroll == true) {
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: false)
        }
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! PopUpCollectionViewCell
        return cell.view
    }
    
    //  Asks the data source for the info view at a given index.
    //
    //
    func detailPopUpViewController(detailPopUpViewController: DetailPopUpViewController, infoViewAtIndexPath indexPath: NSIndexPath) -> UIView {
        return (self.dataSource?.popUpCollectionView(self, infoViewForItemAtIndexPath: indexPath))!
    }
    
    //  Returns to the detail view controller the destination origin for a closing cell.
    //
    //
    func detailPopUpViewController(detailPopUpViewController: DetailPopUpViewController, willCloseAtIndexPath indexPath: NSIndexPath) -> CGPoint {
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath)
        let parent = self.parentViewController
        let frameInWindow = cell!.convertRect(cell!.bounds, toView: parent!.view)
        return frameInWindow.origin
    }

    //  Returns to the detail view controller the expanded frame origin.
    //
    //
    func detailPopUpViewController(detailPopUpViewController: DetailPopUpViewController, expandedOriginForIndexPath indexPath: NSIndexPath) -> CGPoint {
        return getExpandedFrameOrigin()
    }
}

extension PopUpCollectionView: DetailPopUpViewControllerDelegate {
    
    //  On closing the detail view controller, resume user interaction on parent view controller's view.
    //
    //
    func detailPopUpViewController(detailPopUpViewController: DetailPopUpViewController, didEndClose animated: Bool) {
        if let parent = self.parentViewController {            
            // enable user interaction on subviews
            for subview in parent.view.subviews {
                subview.userInteractionEnabled = true
            }
        }
    }
    
    //  Returns the borrowed content view.
    //
    //
    func detailPopUpViewController(detailPopUpViewController: DetailPopUpViewController, returnContentView contentView: UIView, forIndexPath indexPath: NSIndexPath) {
        if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) {
            let cell = cell as! PopUpCollectionViewCell
            cell.setContentView(contentView)
            cell.layoutIfNeeded()
        }
    }
    
    //  Notifies the delegate that the status should be hidden or not.
    //
    //
    func setStatusBarHidden(hidden: Bool, animated: Bool) {
        delegate?.setStatusBarHidden(hidden)
    }
}

extension PopUpCollectionView: UICollectionViewDataSource {
    
    //  Asks the Data Source for the number of items for the collection view.
    //
    //
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.dataSource != nil else {
            return 0
        }
        return (dataSource?.popUpCollectionView(self, numberOfItemsInSection: section))!
    }
    
    //  Asks the Data Source for the content view at a given index path and sets the
    //  collection view's cell.
    //
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PopUpCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! PopUpCollectionViewCell
        let contentView = (dataSource?.popUpCollectionView(self, contentViewAtIndexPath: indexPath))
        cell.setContentView(contentView!)
        return cell
    }
}

extension PopUpCollectionView: UICollectionViewDelegate {
    
    //  When cell is selected, move the cell's content view to the
    //  content view of the Detail Pop Up View Controller's cell.
    //  Then animate the transition.
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            // Insert the cell above all other visible cells
            for visibleCell in collectionView.visibleCells() {
                collectionView.insertSubview(visibleCell, belowSubview: cell)
            }
        
            // Add detail view controller if needed
            if self.detailViewController == nil {
                self.setupDetailViewController()
            }
            self.detailViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)
            self.detailViewController.view.frame = UIScreen.mainScreen().bounds
            self.detailViewController.presentingIndexPath = indexPath
            self.superview?.addSubview(self.detailViewController.view)
            
            if let parent = self.parentViewController {

                // Determine if part of cell is under a top bar or clipped at the bottom
                let frameInWindow = cell.convertRect(cell.bounds, toView: parent.view)
                let isCovered = (frameInWindow.origin.y < 0.0 || (frameInWindow.origin.y + frameInWindow.height) > UIScreen.mainScreen().bounds.height) ? true : false
                
                // If selected cell is partially covered at the top or bottom, auto scroll when opening to ensure smooth closing
                self.shouldAutoScroll = isCovered
                
                // Disable user interaction on all other subviews
                for subview in parent.view.subviews {
                    if subview != self.detailViewController.view {
                         subview.userInteractionEnabled = false
                    }
                }
                
                // Set detail view controller's view in superview's view controller
                self.detailViewController.view.frame.origin = CGPoint(x: frameInWindow.origin.x, y: frameInWindow.origin.y)
                parent.view.addSubview(self.detailViewController.view)
                parent.willMoveToParentViewController(self.detailViewController)
            }
            
            // Force Detail Pop Up View Controller to layout. This will call Detail Pop Up View Controller's Data Source
            self.detailViewController.view.layoutIfNeeded()
            
            // Set the initial alpha for the info view
            self.detailViewController.setPresentingDetailInfoViewAlpha(0.0)
            
            // Animate expansion
            UIView.animateWithDuration(0.18, animations: { () -> Void in
                
                self.detailViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
                self.detailViewController.view.frame.origin = CGPointZero
                self.detailViewController.setPresentingDetailInfoViewAlpha(1.0)
                self.delegate?.setStatusBarHidden(true)
                
                }, completion: { (done) -> Void in
                    
                    self.shouldAutoScroll = true
                    cell.layoutIfNeeded()
            })
        }
    }
}