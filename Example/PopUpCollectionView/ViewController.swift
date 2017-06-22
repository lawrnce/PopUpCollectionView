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
    
    fileprivate var shouldHideStatusBar: Bool = false
    
    fileprivate var demoData: [FLAnimatedImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popUpCollectionView.delegate = self
        self.popUpCollectionView.dataSource = self
        
        self.demoData = [FLAnimatedImage]()
        
        // setup demo data
        for index in 0...10 {
            let gifPath = Bundle.main.url(forResource: "\(index)", withExtension: "gif")
            let data = try? Data(contentsOf: gifPath!)
            let gif = FLAnimatedImage(gifData: data!)
            self.demoData.append(gif!)
            self.popUpCollectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return self.shouldHideStatusBar
    }
}

extension ViewController: PopUpCollectionViewDataSource {
    
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.demoData.count
    }
    
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, contentViewAtIndexPath indexPath: IndexPath) -> UIView {
        let animatedImageView = FLAnimatedImageView(frame: CGRect.zero)
        animatedImageView.contentMode = .scaleAspectFill
        animatedImageView.animatedImage = self.demoData[indexPath.row]
        animatedImageView.sizeToFit()
        animatedImageView.startAnimating()
        return animatedImageView
    }
    
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, infoViewForItemAtIndexPath indexPath: IndexPath) -> UIView {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = "Info for \(indexPath.row)"
        label.font = UIFont(name: "Avenir", size: 24.0)
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        return label
    }
}

extension ViewController: PopUpCollectionViewDelegate {
    
    func popUpCollectionView(_ popUpCollectionView: PopUpCollectionView, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return self.demoData[indexPath.row].size
    }
    
    func setStatusBarHidden(_ hidden: Bool) {
        self.shouldHideStatusBar = hidden
        setNeedsStatusBarAppearanceUpdate()
    }
}
