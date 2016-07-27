//
//  SwiftyJSON+RequireValue.swift
//  Scott Lessans
//
//  Created by Scott Lessans on 7/27/16.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    func requireValue<T>(atPath path: [JSONSubscriptType], transform: (JSON) -> T?) throws -> T {
        let rep = self[path]
        if let val = transform(rep) {
            return val
        }
        throw rep.error!
    }
    func requireValue<T>(atPath path: JSONSubscriptType, transform: (JSON) -> T?) throws -> T {
        return try requireValue(atPath: [path], transform: transform)
    }
}
