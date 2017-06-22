//
//  UIViewExtension.swift
//
//  Created by Lawrence Tran on 3/25/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    //  Extention to make getting the parent view controller easier.
    //
    //
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
