//
//  Actions.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-01-03.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation
import ReSwift

struct GetFamersAction: Action {
    var offset: Int
    var limit: Int
}

struct SuccessGetFamersAction: Action {
    var farmerTableViewControllerState: FarmerTableViewControllerState
}
