//
//  SortOrder.swift
//  Sequential
//
//  Created by nulldragon on 2026-02-18.
//

import Foundation

public enum SortOrder: Int, Sendable
{
    case unspecified = 0
    case byName = 1
    case byDateModified = 2
    case byDateCreated = 3
    case bySize = 4
    case byKind = 5
    case shuffle = 100
    case innate = 200
}
