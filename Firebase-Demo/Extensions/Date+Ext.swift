//
//  Date+Ext.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation


extension Date {
    public func dateString(_ format: String = "EEEE, MMM, d, h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self) // self is that date object itself
        
    }
}
