//
//  ProjectManagerViewModel.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.


import Foundation
import RxSwift

final class ProjectManagerViewModel: ViewModelType {
    //    private var useCase: TaskUseCase?
    private var todoItems: [TaskItemViewModel] = []
    private var doingItems: [TaskItemViewModel] = []
    private var doneItems: [TaskItemViewModel] = []
}

extension ProjectManagerViewModel {
    func transform(input: Input) -> Output {
        
        let update = input.updateTrigger
            .flatMapLatest {
                let todo = Observable.from(optional: self.todoItems)
                let doing = Observable.from(optional: self.doingItems)
                let done = Observable.from(optional: self.doneItems)
                return Observable.combineLatest(todo, doing, done)
            }
        
        let create = input.createTrigger.do(
            onNext: { created in
                self.todoItems.append(created)
            }
        )
        
        return Output(updatedData: update)
    }
}

extension ProjectManagerViewModel {
    struct Input {
        let updateTrigger: Observable<Void>
        let createTrigger: Observable<TaskItemViewModel>
    }
    
    struct Output {
        typealias Items = ([TaskItemViewModel],[TaskItemViewModel],[TaskItemViewModel])
        let updatedData: Observable<Items>
    }
}

