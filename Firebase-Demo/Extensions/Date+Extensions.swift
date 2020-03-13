//
//  Date+Extensions.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

extension Date {
    public func dateString(_ format: String = "MM/dd/YYYY h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        // dateValue().dateString()
        return dateFormatter.string(from: self)
    }
}
