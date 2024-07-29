//
//  Item.swift
//  XP
//
//  Created by Jonathan Kerth on 7/23/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
