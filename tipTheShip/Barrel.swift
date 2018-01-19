//
//  Barrel.swift
//  tipTheShip
//
//  Created by Marla Wallerstein on 7/13/15.
//  Copyright © 2015 Jonah Patinkin. All rights reserved.
//

import Foundation
import UIKit
class Barrel {
    var barrel:UIView
    var x = 0
    init(x:CGFloat, y:CGFloat, height:CGFloat, width:CGFloat){
        let b = UIView(frame: CGRectMake(x, y, 15, 15))
        b.backgroundColor = UIColor.blueColor()
        b.layer.cornerRadius = 10
        b.clipsToBounds = true
        
        barrel = b
    }
}