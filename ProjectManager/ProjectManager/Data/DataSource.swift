//
//  DataSource.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.
    

import Foundation
import RxSwift

protocol DataSource {
    func fetch() -> Observable<[Task]>
    func create(task: Task) -> Observable<Task>
    func update(task: Task) -> Observable<Task>
    func delete(task: Task) -> Observable<Task>
}

final class MemoryDataSource: DataSource {
    static var shared = MemoryDataSource()
    private let subject = BehaviorSubject<[Task]>(value: [])
    private var items: [Task] = [] {
        didSet {
            subject.onNext(items)
            print(items)
        }
    }
    
    func fetch() -> Observable<[Task]> {
        return subject.asObservable()
    }
    
    func create(task: Task) -> Observable<Task> {
        addTask(task: task)
        return Observable.just(task)
    }
    
    func update(task: Task) -> Observable<Task> {
        editTask(task: task)
        return Observable.just(task)
    }
    
    func delete(task: Task) -> Observable<Task> {
        deleteTask(task: task)
        return Observable.just(task)
    }
}

extension MemoryDataSource {
    private func addTask(task: Task) {
        items.append(task)
    }
    
    private func editTask(task: Task) {
        for (index, item) in items.enumerated() where item == task {
            items[index] = task
        }
    }
    
    private func deleteTask(task: Task) {
        for (index, item) in items.enumerated() where item == task {
            items.remove(at: index)
        }
    }
}
