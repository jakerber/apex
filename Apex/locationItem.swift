//
//  locationItem.swift
//  Apex
//
//  Created by Josh Kerber on 5/20/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import Foundation

struct LocationItem
{
    let name: String
    let lat: Double
    let lon: Double
    let bounds = 0.05
    let maxPer: UInt32
}