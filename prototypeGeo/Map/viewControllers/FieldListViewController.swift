//
//  FieldListViewController.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-02-28.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import UIKit

class FieldListViewController: UIViewController, Identifier {
    static var identifier: String = "FieldListViewController"
    
    
    let fieldListViewModel: FieldListViewModel
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(
        fieldListViewModel: FieldListViewModel
    ) {
        self.fieldListViewModel = fieldListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = ContainerMobileFieldListView()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    
    
    

}
