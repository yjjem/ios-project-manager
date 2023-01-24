//
//  Task.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.
    

import Foundation

struct Task: Equatable {
    var title: String
    var description: String
    var expireDate: Date
    var tag: Status
    var uuid: UUID
    
    public static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

enum Status {
    case todo
    case doing
    case done
}
