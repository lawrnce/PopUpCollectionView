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
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    //  Notifies the delegate when to hide the status bar.
    //
    //
    func setStatusBarHidden(_ hidden: Bool)
}

// MARK: - DATA SOURCE
public protocol PopUpCollectionViewDataSource {
    
    //  Asks your data source the number of items in each section.
    //
    //
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, numberOfItemsInSection section: Int) -> Int
    
    //  Asks your data source for the content view at the given index.
    //
    //
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, contentViewAtIndexPath indexPath: IndexPath) -> UIView
    
    //  Asks your data source the info view for the content at a given index.
    //  Set any target selectors for your info view here.
    //
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, infoViewForItemAtIndexPath indexPath: IndexPath) -> UIView
}

open class PopUpCollectionView: UIView {

    // MARK: - PUBLIC VARIABLES
    
    //  Delegate
    //
    //
    open var delegate: PopUpCollectionViewDelegate?
    
    //  Data Source
    //  Pop Up Collection View receives its data just like a normal collection view.
    //
    open var dataSource: PopUpCollectionViewDataSource?
    
    
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
    open func reloadData() {
        self.collectionView.reloadData()
    }

    // MARK: - PRIVATE VARIABLES
    
    //  Main collection view that holds the cells. Pop Up collection view
    //  then transfers a selected cell to a detail view controller
    //  this ensures continuity if the cells are animating.
    fileprivate var collectionView: UICollectionView!
    
    //  Custom waterfall style layout. Pinterest style.
    //  Code taken from https://www.raywenderlich.com/107439/uicollectionview-custom-layout-tutorial-pinterest
    //  Modified for specific use case.
    fileprivate var pinterestLayout: PinterestLayout!
    
    //  When showing a cell's detail, detail view controller is added
    //  as a child view controller to the superview's view controller
    //
    fileprivate var detailViewController: DetailPopUpViewController!
    
    //  Determines if the Pop Up Collection View should scroll
    //  after presenting a detail cell.
    //  This ensures smooth closing animation.
    fileprivate var shouldAutoScroll: Bool = false
    
    // MARK: - PRIVATE METHODS
    
    //  Initial setup
    //
    //
    fileprivate func setup() {
        setupCollectionView()
        setupDetailViewController()
    }
    
    //  Init all nesscessary compoenents
    //
    //
    fileprivate func setupCollectionView() {
        self.pinterestLayout = PinterestLayout()
        self.pinterestLayout.delegate = self
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.pinterestLayout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(PopUpCollectionViewCell.self, forCellWithReuseIdentifier: PopUpCollectionViewCellReuseIdentifier)
        self.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal,
            toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let leadingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal,
            toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .trailing, relatedBy: .equal,
            toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        topConstraint.isActive = true
        bottomConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        self.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    //  Init the detail view controller
    //
    //
    fileprivate func setupDetailViewController() {
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
    fileprivate func getExpandedFrameOrigin() -> CGPoint {
        return CGPoint(x: 0, y: -self.frame.origin.y)
    }
}

extension PopUpCollectionView: PinterestLayoutDelegate {
    
    //  Asks the delegate for the content size. Then scale the content size
    //  so that the width is equal to the column size. Return the scaled height
    //  to the layout.
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let size = self.delegate?.popUpCollectionView(self, sizeForItemAtIndexPath: indexPath)
        return (size?.height)! * (UIScreen.main.bounds.width / 2.0) / (size?.width)!
    }
}

extension PopUpCollectionView: DetailPopUpViewControllerDatasource {
    
    //  Ask the data source for the number of items in each section
    //  for the detail view controller's collection view
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, numberOfItemsInSection section: Int) -> Int {
        return (dataSource?.popUpCollectionView(self, numberOfItemsInSection: section))!
    }
    
    //  Borrows the Pop Up Collection View's cell content view at a given index path
    //  and inserts it into the detail view controller's cell hierarchy.
    //  This ensures smooth transition if the cell is animating.
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, contentViewAtIndexPath indexPath: IndexPath) -> UIView {
        if (self.shouldAutoScroll == true) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
        let cell = self.collectionView.cellForItem(at: indexPath) as! PopUpCollectionViewCell
        return cell.view
    }
    
    //  Asks the data source for the info view at a given index.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, infoViewAtIndexPath indexPath: IndexPath) -> UIView {
        return (self.dataSource?.popUpCollectionView(self, infoViewForItemAtIndexPath: indexPath))!
    }
    
    //  Returns to the detail view controller the destination origin for a closing cell.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, willCloseAtIndexPath indexPath: IndexPath) -> CGPoint {
        let cell = self.collectionView.cellForItem(at: indexPath)
        let parent = self.parentViewController
        let frameInWindow = cell!.convert(cell!.bounds, to: parent!.view)
        return frameInWindow.origin
    }

    //  Returns to the detail view controller the expanded frame origin.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, expandedOriginForIndexPath indexPath: IndexPath) -> CGPoint {
        return getExpandedFrameOrigin()
    }
}

extension PopUpCollectionView: DetailPopUpViewControllerDelegate {
    
    //  On closing the detail view controller, resume user interaction on parent view controller's view.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, didEndClose animated: Bool) {
        if let parent = self.parentViewController {            
            // enable user interaction on subviews
            for subview in parent.view.subviews {
                subview.isUserInteractionEnabled = true
            }
        }
    }
    
    //  Returns the borrowed content view.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, returnContentView contentView: UIView, forIndexPath indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) {
            let cell = cell as! PopUpCollectionViewCell
            cell.setContentView(contentView)
            cell.layoutIfNeeded()
        }
    }
    
    //  Notifies the delegate that the status should be hidden or not.
    //
    //
    func setStatusBarHidden(_ hidden: Bool, animated: Bool) {
        delegate?.setStatusBarHidden(hidden)
    }
}

extension PopUpCollectionView: UICollectionViewDataSource {
    
    //  Asks the Data Source for the number of items for the collection view.
    //
    //
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.dataSource != nil else {
            return 0
        }
        return (dataSource?.popUpCollectionView(self, numberOfItemsInSection: section))!
    }
    
    //  Asks the Data Source for the content view at a given index path and sets the
    //  collection view's cell.
    //
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopUpCollectionViewCellReuseIdentifier, for: indexPath) as! PopUpCollectionViewCell
        let contentView = (dataSource?.popUpCollectionView(self, contentViewAtIndexPath: indexPath))
        cell.setContentView(contentView!)
        return cell
    }
}

extension PopUpCollectionView: UICollectionViewDelegate {
    
    //  When cell is selected, move the cell's content view to the
    //  content view of the Detail Pop Up View Controller's cell.
    //  Then animate the transition.
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            
            // Insert the cell above all other visible cells
            for visibleCell in collectionView.visibleCells {
                collectionView.insertSubview(visibleCell, belowSubview: cell)
            }
        
            // Add detail view controller if needed
            if self.detailViewController == nil {
                self.setupDetailViewController()
            }
            self.detailViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            self.detailViewController.view.frame = UIScreen.main.bounds
            self.detailViewController.presentingIndexPath = indexPath
            self.superview?.addSubview(self.detailViewController.view)
            
            if let parent = self.parentViewController {

                // Determine if part of cell is under a top bar or clipped at the bottom
                let frameInWindow = cell.convert(cell.bounds, to: parent.view)
                let isCovered = (frameInWindow.origin.y < 0.0 || (frameInWindow.origin.y + frameInWindow.height) > UIScreen.main.bounds.height) ? true : false
                
                // If selected cell is partially covered at the top or bottom, auto scroll when opening to ensure smooth closing
                self.shouldAutoScroll = isCovered
                
                // Disable user interaction on all other subviews
                for subview in parent.view.subviews {
                    if subview != self.detailViewController.view {
                         subview.isUserInteractionEnabled = false
                    }
                }
                
                // Set detail view controller's view in superview's view controller
                self.detailViewController.view.frame.origin = CGPoint(x: frameInWindow.origin.x, y: frameInWindow.origin.y)
                parent.view.addSubview(self.detailViewController.view)
                parent.willMove(toParentViewController: self.detailViewController)
            }
            
            // Force Detail Pop Up View Controller to layout. This will call Detail Pop Up View Controller's Data Source
            self.detailViewController.view.layoutIfNeeded()
            
            // Set the initial alpha for the info view
            self.detailViewController.setPresentingDetailInfoViewAlpha(0.0)
            
            // Animate expansion
            UIView.animate(withDuration: 0.18, animations: { () -> Void in
                
                self.detailViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                self.detailViewController.view.frame.origin = CGPoint.zero
                self.detailViewController.setPresentingDetailInfoViewAlpha(1.0)
                self.delegate?.setStatusBarHidden(true)
                
                }, completion: { (done) -> Void in
                    
                    self.shouldAutoScroll = true
                    cell.layoutIfNeeded()
            })
        }
    }
}
