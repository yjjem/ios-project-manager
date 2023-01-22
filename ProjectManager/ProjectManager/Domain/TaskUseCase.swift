//
//  TaskUseCase.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.
    

import RxSwift

protocol TaskUseCas {
    func tasks() -> Observable<[Task]>
    func update(task: Task) -> Observable<Void>
    func delete(task: Task) -> Observable<Void>   
}
