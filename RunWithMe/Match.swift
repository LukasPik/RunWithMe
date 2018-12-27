//
//  Match.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 27/12/2018.
//  Copyright © 2018 Łukasz Pik. All rights reserved.
//

import Foundation
import UIKit

public class Match {
    var distance: Int
    var opponent: String
    
    init() {
        distance = 0;
        opponent = "None"
    }
    
    init(distance: Int) {
        self.distance = distance
        self.opponent = "None"
    }
    
    init(opponent: String, distance: Int) {
        self.distance = distance
        self.opponent = opponent
    }
    
    func createMatch() -> String {
        var result = "[dist:"
        result += String(self.distance)
        result += ", opponent:" + self.opponent
        result += ", "
        return result
    }
}
