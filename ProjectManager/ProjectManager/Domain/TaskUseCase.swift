//
//  TaskUseCase.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.
    

import RxSwift

protocol TaskUseCase {
    func getTasks() -> Observable<[Task]>
    func create(task: Task) -> Observable<Task>
    func update(task: Task) -> Observable<Task>
    func delete(task: Task) -> Observable<Task>
}

final class TaskItemsUseCase {
    let datasource: DataSource
    
    init(datasource: DataSource) {
        self.datasource = datasource
    }
}

extension TaskItemsUseCase: TaskUseCase {
    func getTasks() -> Observable<[Task]> {
        return datasource.fetch()
    }
    
    func create(task: Task) -> Observable<Task> {
        return datasource.create(task: task)
    }
    
    func update(task: Task) -> Observable<Task> {
        return datasource.update(task: task)
    }
    
    func delete(task: Task) -> RxSwift.Observable<Task> {
        return datasource.delete(task: task)
    }
}
