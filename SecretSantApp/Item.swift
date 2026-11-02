//
//  Item.swift
//  SecretSantApp
//
//  Created by Blas Gimeno on 02/11/2026.
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
