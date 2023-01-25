//
//  TaskSwitchViewModel.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.
    

import Foundation
import RxSwift

final class TaskSwitchViewModel: ViewModelType {
    private var useCase: TaskItemsUseCase
    private var task: Task

    init(useCase: TaskItemsUseCase, task: Task) {
        self.useCase = useCase
        self.task = task
    }
}

// MARK: Function

extension TaskSwitchViewModel {
    func transform(input: Input) -> Output {
        let switchDoing = input.doingTrigger
            .flatMapLatest { _ in
                let switched = self.switchTask(to: .doing)
                return self.useCase.update(task: switched)
            }

        let switchDone = input.doneTrigger
            .flatMapLatest { _ in
                let switched = self.switchTask(to: .done)
                return self.useCase.update(task: switched)
            }

        return Output(doingSwitched: switchDoing,
                      doneSwitched: switchDone)
    }
    
    private func switchTask(to tag: Status) -> Task {
        return Task(title: task.title,
                    description: task.description,
                    expireDate: task.expireDate,
                    tag: tag,
                    uuid: task.uuid)
    }
}

// MARK: Input & Output

extension TaskSwitchViewModel {
    struct Input {
        let doingTrigger: Observable<Void>
        let doneTrigger: Observable<Void>
    }
    struct Output {
        let doingSwitched: Observable<Task>
        let doneSwitched: Observable<Task>
    }
}
