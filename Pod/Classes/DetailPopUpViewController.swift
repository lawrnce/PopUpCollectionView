//
//  DetailPopUpViewController.swift
//  PopUpCollectionView
//
//  Created by Lawrence Tran on 3/30/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

// MARK: - DELEGATE
protocol DetailPopUpViewControllerDelegate {
    
    //  Notifies the delegate that the detail view has finished its closing animation.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, didEndClose animated: Bool)
    
    //  Returns the content view to the Pop Up Collection View.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, returnContentView contentView: UIView, forIndexPath indexPath: IndexPath)
    
    //  Notifies the delegate of a status bar change.
    //
    //
    func setStatusBarHidden(_ hidden: Bool, animated: Bool)
}

// MARK: - DATA SOURCE
protocol DetailPopUpViewControllerDatasource {
    
    //  Asks the data source for the number of items in the PopUp Collection View.
    //  Only one section is used internally as each cell is full screen.
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, numberOfItemsInSection section:Int) -> Int
    
    //  Borrows the selected cell view from the PopUp Collection View.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, contentViewAtIndexPath indexPath: IndexPath) -> UIView
    
    //  Asks the data source for the info view of a cell.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, infoViewAtIndexPath indexPath: IndexPath) -> UIView
    
    //  Asks the Pop Up Collection View for the position of the current cell to return.
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, willCloseAtIndexPath indexPath: IndexPath) -> CGPoint
    
    //
    //
    //
    func detailPopUpViewController(_ detailPopUpViewController: DetailPopUpViewController, expandedOriginForIndexPath indexPath: IndexPath) -> CGPoint
}

class DetailPopUpViewController: UIViewController {

    // MARK: - PUBLIC VARIABLES
    
    //  Setting the presenting index path sets the detail collection to the same index.
    //
    //
    var presentingIndexPath: IndexPath! {
        didSet {
            if (self.collectionView != nil) {
                self.collectionView.scrollToItem(at: self.presentingIndexPath, at: .centeredHorizontally, animated: false)
            }
            
        }
    }
    
    //  Delegate
    //
    //
    var delegate: DetailPopUpViewControllerDelegate?
    
    //  Data Source
    // 
    //
    var dataSource: DetailPopUpViewControllerDatasource?
    
    // MARK: - PUBLIC METHODS
    
    //  Sets the alpha of the current cell's info view.
    //  This is used to make pretty transitions.
    //
    func setPresentingDetailInfoViewAlpha(_ alpha: CGFloat) {
        if let cell = getCurrentCell() {
            cell.infoScrollView.alpha = alpha
        }
    }
    
    //  Handles closing animation
    //
    //
    func handleDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        // Static parameters for each gesture instance
        struct ClosingParameters {
            static var cell: DetailPopUpCollectionViewCell!
            static var cellIndexPath: IndexPath!
            static var endPoint: CGPoint = CGPoint.zero
            static var distance: Float = 0.0
            static var progress: CGFloat = 0.0
            static var shouldShowStatusBar: Bool = false
        }
        
        // Dragging down
        if gestureRecognizer.translation(in: self.view).y != 0 {
            
            let translationY = Float(gestureRecognizer.translation(in: self.view).y)
            
            switch (gestureRecognizer.state) {
                
            case .changed:
                
                // Set initial parameters for new gesture
                if (ClosingParameters.cell == nil || ClosingParameters.cellIndexPath == nil) {
                    if let cell = getCurrentCell() {
                        
                        ClosingParameters.cell = cell
                        ClosingParameters.cellIndexPath = self.collectionView.indexPath(for: cell)
                        
                        // Get destination point
                        if let point = self.dataSource?.detailPopUpViewController(self, willCloseAtIndexPath: ClosingParameters.cellIndexPath) {
                            ClosingParameters.endPoint = point
                            
                            // Get distance to endpoint
                            ClosingParameters.distance = getDistanceToDestinationFrame(point)
                        }
                        
                        // Return remaining reusable cell's content view
                        self.returnLingeringContentView(ClosingParameters.cellIndexPath)
                    }
                }
                
                // Cacluated percentage traveled to endpoint
                ClosingParameters.progress = CGFloat(min(Double(translationY / ClosingParameters.distance), 1.0))
                
                // If passed status bar threshold, notify the PopUp Collection View
                if (self.view.frame.origin.y > 20.0 && ClosingParameters.shouldShowStatusBar == false) {
                    ClosingParameters.shouldShowStatusBar = true
                    self.delegate?.setStatusBarHidden(false, animated: true)
                } else if (self.view.frame.origin.y <= 20.0 && ClosingParameters.shouldShowStatusBar == true) {
                    ClosingParameters.shouldShowStatusBar = false
                    self.delegate?.setStatusBarHidden(true, animated: true)
                }
                
                // Set Scale
                let scale = min(1.0 - 0.5 * ClosingParameters.progress, 1.0)
                self.view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
                
                // Set translation
                let xOffset = max(ClosingParameters.endPoint.x * ClosingParameters.progress, 0.0)
                let yOffset = max(ClosingParameters.endPoint.y * ClosingParameters.progress, 0.0)
                self.view.frame = CGRect(x: xOffset, y: yOffset, width: self.view.frame.width, height: self.view.frame.height)
                
                // Set info view alpha
                ClosingParameters.cell.infoScrollView.alpha = 1 - ClosingParameters.progress
                
            case .ended:
                
                // Force close
                if (ClosingParameters.progress > 0.3) {
                    forceClose(ClosingParameters.endPoint, forCell: ClosingParameters.cell)
                    
                    // Cancel close
                } else {
                    self.delegate?.setStatusBarHidden(true, animated: true)
                    cancelClose(ClosingParameters.cell)
                }
                
                // Clear Closing Parameters
                ClosingParameters.cell = nil
                ClosingParameters.cellIndexPath = nil
                ClosingParameters.endPoint = CGPoint.zero
                ClosingParameters.distance = 0.0
                ClosingParameters.progress = 0.0
                
            default:
                break
                
            }
            
        }
    }
    
    // MARK: - PRIVATE VARIABLES
    
    //  Collection view that displays the content.
    //
    //
    fileprivate var collectionView: UICollectionView!
    
    //  Basic flow layout for full screen cells.
    //
    //
    fileprivate var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - PRIVATE METHODS
    
    //  Add a pan gesture recognizer for closing.
    //
    //
    fileprivate func setupPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DetailPopUpViewController.handleDrag(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    //  Init the collection view
    //
    //
    fileprivate func setupCollectionView() {
        self.flowLayout = UICollectionViewFlowLayout()
        self.flowLayout.minimumInteritemSpacing = 0.0
        self.flowLayout.minimumLineSpacing = 0.0
        self.flowLayout.itemSize = UIScreen.main.bounds.size
        self.flowLayout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: self.flowLayout)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.contentInset = UIEdgeInsets.zero
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.isPagingEnabled = true
        self.collectionView.register(DetailPopUpCollectionViewCell.self, forCellWithReuseIdentifier: DetailPopUpCollectionViewCellReuseIdentifier)
        self.view.addSubview(self.collectionView)
    }
    
    //  Calculates the distance between the origin of the window to the origin
    //  of the destination cell in the Pop Up Collection View.
    //
    fileprivate func getDistanceToDestinationFrame(_ destinationPoint: CGPoint) -> Float {
        let p1 = self.dataSource?.detailPopUpViewController(self, expandedOriginForIndexPath: IndexPath())
        let p2 = destinationPoint
        return Float(hypot(p1!.x - p2.x, p1!.y - p2.y))
    }
    
    //  Cancels closing and animates back to presenting state.
    //
    //
    fileprivate func cancelClose(_ cell: DetailPopUpCollectionViewCell) {
        UIView.animate(withDuration: 0.18, animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            self.view.frame = UIScreen.main.bounds
            cell.infoScrollView.alpha = 1.0
            }, completion: { (done) -> Void in
        }) 
    }
    
    //  Close the Detail View Controller.
    //
    //
    fileprivate func forceClose(_ endPoint: CGPoint, forCell cell: DetailPopUpCollectionViewCell) {
        UIView.animate(withDuration: 0.12, animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            self.view.frame = CGRect(x: endPoint.x, y: endPoint.y, width: self.view.frame.width, height: self.view.frame.height)
            cell.infoScrollView.alpha = 0.0
            }, completion: { (done) -> Void in
                self.delegate?.detailPopUpViewController(self, returnContentView: cell.detailContentView, forIndexPath: cell.indexPath as IndexPath)
                self.delegate?.detailPopUpViewController(self, didEndClose: true)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }) 
    }

    //  Gets the current visible cell.
    //
    //
    fileprivate func getCurrentCell() -> DetailPopUpCollectionViewCell? {
        for cell in self.collectionView.visibleCells {
            return cell as? DetailPopUpCollectionViewCell
        }
        return nil
    }
    
    //  Gets the current index for visible cell.
    //
    //
    fileprivate func getCurrentCellIndexPath() -> IndexPath? {
        for cell in self.collectionView.visibleCells {
            return self.collectionView.indexPath(for: cell)!
        }
        return nil
    }
    
    //  When closing there will be one reusable collection view cell left.
    //  Force a dequeue to call prepareForReuse on that remaining cell.
    //
    fileprivate func returnLingeringContentView(_ indexPath: IndexPath) {
        self.collectionView.dequeueReusableCell(withReuseIdentifier: DetailPopUpCollectionViewCellReuseIdentifier, for: indexPath)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPanGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DetailPopUpViewController: UICollectionViewDataSource {
    
    //  Asks the data source for the number of items.
    //
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.dataSource?.detailPopUpViewController(self, numberOfItemsInSection: section))!
    }
    
    //  Asks the data source for the content and info views.
    //  Ads them into a detail cell.
    //
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailPopUpCollectionViewCellReuseIdentifier, for: indexPath) as! DetailPopUpCollectionViewCell
        cell.delegate = self
        let contentView = self.dataSource?.detailPopUpViewController(self, contentViewAtIndexPath: indexPath)
        let infoView = self.dataSource?.detailPopUpViewController(self, infoViewAtIndexPath: indexPath)
        cell.setContentView(contentView!, withInfoView: infoView!)
        cell.indexPath = indexPath
        return cell
    }
}

extension DetailPopUpViewController: DetailPopUpCollectionViewCellDelegate {
    
    //  Sends the returning content view to the Pop Up Collection View.
    //  This ensures consistent animation.
    //
    func detailPopUpCollectionViewCell(_ cell: DetailPopUpCollectionViewCell, returnContentView contentView: UIView, forIndexPath indexPath: IndexPath) {
        self.delegate?.detailPopUpViewController(self, returnContentView: contentView, forIndexPath: indexPath)
    }
}
