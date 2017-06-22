//
//  PopUpCollectionViewCell.swift
//  PopUpCollectionView
//
//  Created by Lawrence Tran on 3/30/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

let PopUpCollectionViewCellReuseIdentifier = "PopUpCollectionViewCellReuseIdentifier"

class PopUpCollectionViewCell: UICollectionViewCell {
    
    // MARK: - PUBLIC
    
    //  Content view for the cell. Named 'view' as
    //  contentView is a property of UICollectionViewCell
    //
    var view: UIView!
    
    //  Adds the content view to the cell
    //  adjusts layout accordingly
    //
    func setContentView(_ contentView: UIView) {
        self.view = contentView
        self.view.frame.size = self.frame.size
        self.addSubview(self.view)
        self.layoutIfNeeded()
    }
    
    // MARK: - SUBCLASS OVERRIDE
    
    //  Return the borrowed content view to the Pop Collection View
    //  Resets the cell for reuse.
    //
    override func prepareForReuse() {
        self.view.removeFromSuperview()
        self.view = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
}
