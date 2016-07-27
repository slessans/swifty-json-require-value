//
//  SwiftyJSON+RequireValue.swift
//  Scott Lessans
//
//  Created by Scott Lessans on 7/27/16.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation
import SwiftyJSON

// TODO: better nested error messages (for instance, requireArrayOfValues doesnt give context on type error)

enum JsonDeserializationError: ErrorType {
    case PathError(json: JSON, path: [JSONSubscriptType], underlying: ErrorType)
    case TypeError(json: JSON, expected: Any.Type, actual: Type)
}

extension JsonDeserializationError: CustomStringConvertible {
    var description: String {
        switch self {
        case .PathError(_, let path, let underlying):
            return "Invalid path \"\(path)\": \(underlying)"
        case .TypeError(_, let expected, let actual):
            return "Expected \(expected), got \(actual)"
        }
    }
}

extension JSON {
    func requireType<T>(transform: (JSON) -> T?) throws -> T {
        if let val = transform(self) {
            return val
        }
        throw JsonDeserializationError.TypeError(json: self, expected: T.self, actual: self.type)
    }
    func requireArrayOfType<T>(transform: (JSON) -> T?) throws -> [T] {
        return try self.requireType({ $0.array }).map({ try $0.requireType(transform) })
    }
    func requireExists(atPath path: [JSONSubscriptType]) throws -> JSON {
        let rep = self[path]
        if let e = rep.error {
            throw JsonDeserializationError.PathError(json: self, path: path, underlying: e)
        }
        if !rep.exists() {
            fatalError("should have been caught by error above?")
        }
        return rep
    }
    func requireValue<T>(atPath path: [JSONSubscriptType], transform: (JSON) -> T?) throws -> T {
        return try self.requireExists(atPath: path).requireType(transform)
    }
    func requireValue<T>(atPath path: JSONSubscriptType, transform: (JSON) -> T?) throws -> T {
        return try requireValue(atPath: [path], transform: transform)
    }
    func requireArrayOfValues<T>(atPath path: [JSONSubscriptType], transform: (JSON) -> T?) throws -> [T] {
        return try self.requireExists(atPath: path).requireType({ $0.array }).map({ try $0.requireType(transform) })
    }
    func requireArrayOfValues<T>(atPath path: JSONSubscriptType, transform: (JSON) -> T?) throws -> [T] {
        return try requireArrayOfValues(atPath: [path], transform: transform)
    }
}
