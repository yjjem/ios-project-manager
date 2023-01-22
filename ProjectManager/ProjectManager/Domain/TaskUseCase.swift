//
//  TaskUseCase.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.
    

import RxSwift

protocol TaskUseCase {
    func getTasks() -> Observable<([Task],[Task],[Task])>
    func update(task: Task) -> Observable<Void>
    func delete(task: Task) -> Observable<Void>   
}
