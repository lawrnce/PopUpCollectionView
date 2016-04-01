//
//  ViewController.swift
//  PopUpCollectionView
//
//  Created by Lawrence Tran on 03/31/2016.
//  Copyright (c) 2016 Lawrence Tran. All rights reserved.
//

import UIKit
import FLAnimatedImage
import PopUpCollectionView

class ViewController: UIViewController {
    
    @IBOutlet weak var popUpCollectionView: PopUpCollectionView!
    
    private var shouldHideStatusBar: Bool = false
    
    private var demoData: [FLAnimatedImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popUpCollectionView.delegate = self
        self.popUpCollectionView.dataSource = self
        
        self.demoData = [FLAnimatedImage]()
        
        // setup demo data
        for index in 0...10 {
            let gifPath = NSBundle.mainBundle().URLForResource("\(index)", withExtension: "gif")
            let data = NSData(contentsOfURL: gifPath!)
            let gif = FLAnimatedImage(GIFData: data!)
            self.demoData.append(gif!)
            self.popUpCollectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.shouldHideStatusBar
    }
}

extension ViewController: PopUpCollectionViewDataSource {
    
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.demoData.count
    }
    
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, contentViewAtIndexPath indexPath: NSIndexPath) -> UIView {
        let animatedImageView = FLAnimatedImageView(frame: CGRectZero)
        animatedImageView.contentMode = .ScaleAspectFill
        animatedImageView.animatedImage = self.demoData[indexPath.row]
        animatedImageView.sizeToFit()
        animatedImageView.startAnimating()
        return animatedImageView
    }
    
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, infoViewForItemAtIndexPath indexPath: NSIndexPath) -> UIView {
        let label = UILabel(frame: CGRectZero)
        label.textAlignment = .Center
        label.baselineAdjustment = .AlignCenters
        label.text = "Info for \(indexPath.row)"
        label.font = UIFont(name: "Avenir", size: 24.0)
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100)
        return label
    }
}

extension ViewController: PopUpCollectionViewDelegate {
    
    func popUpCollectionView(popUpCollectionView: PopUpCollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.demoData[indexPath.row].size
    }
    
    func setStatusBarHidden(hidden: Bool) {
        self.shouldHideStatusBar = hidden
        setNeedsStatusBarAppearanceUpdate()
    }
}