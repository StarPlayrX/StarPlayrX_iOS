//
//  TabViewController.swift
//  StarPlayr
//
//  Created by Todd Bruss on 2/10/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit


class TabController: UITabBarController {
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
 		
        let appearance = tabBar.standardAppearance
s
        appearance.shadowImage = nil
        appearance.shadowColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
        appearance.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
        tabBar.standardAppearance = appearance
        tabBar.layer.borderWidth = 0.0
        tabBar.clipsToBounds = true
        delegate = self
    }
}


