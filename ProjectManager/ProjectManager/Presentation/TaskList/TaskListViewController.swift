//
//  TaskListViewController.swift
//  ProjectManager
//
//  Copyright (c) 2023 Jeremy All rights reserved.

import UIKit
import RxSwift
import RxCocoa

fileprivate enum Titles {
    static let todo = "TODO"
    static let doing = "DOING"
    static let done = "DONE"
    static let navigationItem = "Project Manager"
}

fileprivate enum Identifier {
    static let cellReuse = "task"
}

final class TaskListViewController: UIViewController {
    
    var viewModel: TaskListViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: View(s)
    
    private let todoTableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: Identifier.cellReuse)
        table.separatorStyle = .none
        table.backgroundColor = .systemGray6
        
        return table
    }()
    private let doingTableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: Identifier.cellReuse)
        table.separatorStyle = .none
        table.backgroundColor = .systemGray6
        
        return table
    }()
    private let doneTableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: Identifier.cellReuse)
        table.separatorStyle = .none
        table.backgroundColor = .systemGray6
        
        return table
    }()
    
    private let todoStatusView: TaskStatusInfoView = {
        let view = TaskStatusInfoView()
        view.setTitle(with: Titles.todo)
        view.backgroundColor = .systemGray6
        
        return view
    }()
    private let doingStatusView: TaskStatusInfoView = {
        let view = TaskStatusInfoView()
        view.setTitle(with: Titles.doing)
        view.backgroundColor = .systemGray6
        
        return view
    }()
    private let doneStatusView: TaskStatusInfoView = {
        let view = TaskStatusInfoView()
        view.setTitle(with: Titles.done)
        view.backgroundColor = .systemGray6
        
        return view
    }()
    
    private let todoStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        
        return stack
    }()
    private let doingStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        
        return stack
    }()
    private let doneStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        
        return stack
    }()
    
    private let wholeStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        
        return stack
    }()
    
    // MARK: Override(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationController()
        combineViews()
        configureViewConstraints()
        addTableviewLongPressRecognizers()
        performBindings()
    }
    
    // MARK: Private Function(s)
    
    private func configureNavigationController() {
        let rightAddButton = UIBarButtonItem(barButtonSystemItem: .add,
                                             target: self,
                                             action: #selector(tapNavigationAddButton))
        navigationItem.rightBarButtonItem = rightAddButton
        navigationItem.title = Titles.navigationItem
    }
    
    private func presentTaskTagSwitcher(task: Task, on view: UIView) {
        let switcher = SwitchTaskViewController()
        switcher.sourceView(view: view)
        let useCase = TaskItemsUseCase(datasource: MemoryDataSource.shared)
        let viewModel = SwitchTaskViewModel(useCase: useCase, task: task)
        switcher.viewModel = viewModel
        
        present(switcher, animated: true)
    }
    
    private func createEditView(with item: TaskItemViewModel) -> UINavigationController {
        let editView = EditTaskViewController()
        let useCase = TaskItemsUseCase(datasource: MemoryDataSource.shared)
        editView.viewModel = EditTaskViewModel(item: item, useCase: useCase)
        let navigation = UINavigationController(rootViewController: editView)
        
        return navigation
    }
    
    private func addTableviewLongPressRecognizers() {
        let todoLongPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didLongPress)
        )
        let doingLongPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didLongPress)
        )
        
        let doneLongPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didLongPress)
        )
        
        todoTableView.addGestureRecognizer(todoLongPressGesture)
        doingTableView.addGestureRecognizer(doingLongPressGesture)
        doneTableView.addGestureRecognizer(doneLongPressGesture)
    }
    
    private func combineViews() {
        todoStackView.addArrangedSubview(todoStatusView)
        todoStackView.addArrangedSubview(todoTableView)
        
        doingStackView.addArrangedSubview(doingStatusView)
        doingStackView.addArrangedSubview(doingTableView)
        
        doneStackView.addArrangedSubview(doneStatusView)
        doneStackView.addArrangedSubview(doneTableView)
        
        wholeStackView.addArrangedSubview(todoStackView)
        wholeStackView.addArrangedSubview(doingStackView)
        wholeStackView.addArrangedSubview(doneStackView)
        
        view.addSubview(wholeStackView)
        view.backgroundColor = .systemGray3
    }
    
    private func configureViewConstraints() {
        NSLayoutConstraint.activate([
            wholeStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wholeStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wholeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wholeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc
    private func tapNavigationAddButton() {
        let addTaskView = AddTaskViewController()
        addTaskView.modalPresentationStyle = .formSheet
        let useCase = TaskItemsUseCase(datasource: MemoryDataSource.shared)
        addTaskView.viewmodel = AddTaskViewModel(useCase: useCase)
        let navigation = UINavigationController(rootViewController: addTaskView)
        
        present(navigation, animated: true)
    }
    
    @objc
    private func didLongPress(_ recognizer: UIGestureRecognizer) {
        let pressPoint = recognizer.location(in: recognizer.view)
        guard let tableView = recognizer.view as? UITableView,
              let indexPath = tableView.indexPathForRow(at: pressPoint),
              let cell = tableView.cellForRow(at: indexPath) as? TaskCell,
              let cellTask = cell.viewModel?.task
        else {
            return
        }
        
        presentTaskTagSwitcher(task: cellTask, on: cell)
    }
    
    // MARK: Binding(s)
    
    private func performBindings() {
        bindViewModel()
        bindSelectionActionToCell()
    }
    
    private func bindSelectionActionToCell() {
        todoTableView.rx
            .modelSelected(TaskItemViewModel.self)
            .subscribe(onNext: { item in
                let view = self.createEditView(with: item)
                self.present(view, animated: true)
            })
            .disposed(by: disposeBag)
        
        doingTableView.rx
            .modelSelected(TaskItemViewModel.self)
            .subscribe(onNext: { item in
                let view = self.createEditView(with: item)
                self.present(view, animated: true)
            })
            .disposed(by: disposeBag)
        
        doneTableView.rx
            .modelSelected(TaskItemViewModel.self)
            .subscribe(
                onNext: { item in
                    let view = self.createEditView(with: item)
                    self.present(view, animated: true)
                })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        guard let viewModel = self.viewModel else { return }
        
        let todoDeletedTrigger = todoTableView.rx
            .modelDeleted(TaskItemViewModel.self)
            .asObservable()
        let doingDeletedTrigger = doingTableView.rx
            .modelDeleted(TaskItemViewModel.self)
            .asObservable()
        let doneDeletedTrigger = doneTableView.rx
            .modelDeleted(TaskItemViewModel.self)
            .asObservable()
        let deletedTrigger = Observable.merge(todoDeletedTrigger,
                                              doingDeletedTrigger,
                                              doneDeletedTrigger)
        let updateTrigger = self.rx
            .methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in }
        
        let input = TaskListViewModel.Input(update: updateTrigger,
                                            delete: deletedTrigger)
        let output = viewModel.transform(input: input)
        
        output.deletedItem
            .subscribe()
            .disposed(by: disposeBag)
        
        output.todoItems
            .map { $0.count }
            .subscribe(onNext: { count in
                self.todoStatusView.setUpCount(count: count)
            })
            .disposed(by: disposeBag)
        
        output.doingItems
            .map { $0.count }
            .subscribe(onNext: { count in
                self.doingStatusView.setUpCount(count: count)
            })
            .disposed(by: disposeBag)
        
        output.doneItems
            .map { $0.count }
            .subscribe(onNext: { count in
                self.doneStatusView.setUpCount(count: count)
            })
            .disposed(by: disposeBag)
        
        output.todoItems
            .bind(to: todoTableView.rx.items) { tableview, index, item in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: Identifier.cellReuse)
                        as? TaskCell
                else {
                    return TaskCell()
                }
                cell.viewModel = item
                cell.setupUsingViewModel()
                
                return cell
            }
            .disposed(by: disposeBag)
        
        output.doingItems
            .bind(to: doingTableView.rx.items) { tableview, index, item in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: Identifier.cellReuse)
                        as? TaskCell
                else {
                    return TaskCell()
                }
                cell.viewModel = item
                cell.setupUsingViewModel()
                
                return cell
            }
            .disposed(by: disposeBag)
        
        output.doneItems
            .bind(to: doneTableView.rx.items) { tableview, index, item in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: Identifier.cellReuse)
                        as? TaskCell
                else {
                    return TaskCell()
                }
                cell.viewModel = item
                cell.setupUsingViewModel()
                
                return cell
            }
            .disposed(by: disposeBag)
    }
}

// MARK: Delegate(s)

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
