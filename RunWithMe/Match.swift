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
    var id: Int
    var distance: Int
    var opponent: String
    var creator: String
    var date: String
    
    init() {
        distance = 0;
        opponent = "None"
        id = 0;
        creator = "None"
        date = ""
    }
    
    init(distance: Int) {
        self.distance = distance
        self.opponent = "None"
        self.id = 0
        self.creator = "None"
        self.date = ""
    }
    
    init(opponent: String, distance: Int, id: Int, date: String) {
        self.distance = distance
        self.opponent = opponent
        self.id = id
        self.creator = ""
        self.date = date
    }

    init(opponent: String, distance: Int, id: Int, creator: String, date: String) {
        self.distance = distance
        self.opponent = opponent
        self.id = id
        self.creator = creator
        self.date = date
    }
    
    init(opponent: String, distance: Int, id: Int, creator: String) {
        self.distance = distance
        self.opponent = opponent
        self.id = id
        self.creator = creator
        self.date = ""
    }
    
    func createMatch() -> String {
        var result = "[dist:"
        result += String(self.distance)
        result += ", opponent:" + self.opponent
        result += ", creator:" + self.creator
        return result
    }
}
