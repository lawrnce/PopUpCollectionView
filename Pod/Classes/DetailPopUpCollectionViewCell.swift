//
//  DetailPopUpCollectionViewCell.swift
//  PopUpCollectionView
//
//  Created by Lawrence Tran on 3/30/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

let DetailPopUpCollectionViewCellReuseIdentifier = "DetailPopUpCollectionViewCellReuseIdentifier"

// MARK: - DELEGATE

//  Cell will call delegate on reuse to return the content view.
//
//
protocol DetailPopUpCollectionViewCellDelegate {
    func detailPopUpCollectionViewCell(cell: DetailPopUpCollectionViewCell, returnContentView contentView: UIView, forIndexPath indexPath: NSIndexPath)
}

class DetailPopUpCollectionViewCell: UICollectionViewCell {
    
    // MARK: - PUBLIC VARIABLES
    
    //  Main view of the detail cell. Is always above the info view
    //  Called detailContentView as content view is a variable of
    //  UICollectionViewCell
    var detailContentView: UIView!
    
    
    //  Info view for the current content
    //
    //
    var infoScrollView: UIScrollView!
    
    //  Delegate for the cell
    //
    //
    var delegate: DetailPopUpCollectionViewCellDelegate?
    
    //  Keep track of the content view's index path
    //  to return to the delegate
    //
    var indexPath: NSIndexPath!
    
    // MARK: - PUBLIC METHODS
    
    //  Use this to set the content view.
    //  Cell will readjust aspect ratios accordingly.
    //
    func setContentView(contentView: UIView, withInfoView infoView: UIView) {
        self.detailContentView = contentView
        self.detailContentView.frame = CGRect(x: 0, y: 0,
            width: UIScreen.mainScreen().bounds.width,
            height: contentView.frame.height * UIScreen.mainScreen().bounds.width / contentView.frame.width)
        self.infoScrollView = UIScrollView(frame: CGRect(x: 0, y: self.detailContentView.frame.height,
            width: UIScreen.mainScreen().bounds.width,
            height: UIScreen.mainScreen().bounds.height - self.detailContentView.frame.height))
        self.infoScrollView.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.infoScrollView)
        self.addSubview(detailContentView)
        self.infoScrollView.addSubview(infoView)
    }
    
    // MARK: - SUBCLASS OVERRIDE
    
    //  Return the borrowed content view to the Pop Collection View
    //  Resets the cell for reuse.
    //
    override func prepareForReuse() {
        self.delegate?.detailPopUpCollectionViewCell(self, returnContentView: self.detailContentView, forIndexPath: self.indexPath)
        self.indexPath = nil
        self.infoScrollView.removeFromSuperview()
        self.infoScrollView = nil
        self.delegate = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
    }
}
