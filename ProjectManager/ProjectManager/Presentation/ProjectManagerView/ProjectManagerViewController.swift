//
//  ProjectManager - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import RxSwift
import RxCocoa

final class ProjectManagerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: View Initialization
    
    var todoTableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: "task")
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCell))
        return table
    }()
    var doingTableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: "task")
        return table
    }()
    var doneTableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: "task")
        return table
    }()
    
    var todoStatusView: TaskStatusView = {
        let view = TaskStatusView()
        view.taskNameLabel.text = "TODO"
        return view
    }()
    var doingStatusView: TaskStatusView = {
        let view = TaskStatusView()
        view.taskNameLabel.text = "Doing"
        return view
    }()
    var doneStatusView: TaskStatusView = {
        let view = TaskStatusView()
        view.taskNameLabel.text = "DONE"
        return view
    }()
    
    var todoStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        return stack
    }()
    var doingStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        
        return stack
    }()
    var doneStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        
        return stack
    }()
    
    var wholeStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        return stack
    }()
    
    // MARK: ViewModel
    var viewModel: ProjectManagerViewModel?
    let disposeBag = DisposeBag()
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationController()
        configureView()
        combineViews()
        bindViewModel()
        cellAction()
        
        bindLongPress()
    }
}

// MARK: Functions
extension UITableView {
    @objc func didLongPress() {
        print("LLLLL")
    }
}

extension ProjectManagerViewController {
    
    private func setLongPress() {
        let todoLongPressGesture = UILongPressGestureRecognizer(target: todoTableView,
                                                                action: #selector(todoTableView.didLongPress))
//        todoLongPressGesture.minimumPressDuration = 1
        todoLongPressGesture.numberOfTapsRequired = 1
        let doingLongPressGesture = UILongPressGestureRecognizer(target: doingTableView,
                                                                 action: #selector(doingTableView.didLongPress))
//        doingLongPressGesture.minimumPressDuration = 1
        doingLongPressGesture.numberOfTapsRequired = 1
        let doneLongPressGesture = UILongPressGestureRecognizer(target: doneTableView,
                                                                action: #selector(doneTableView.didLongPress))
//        doneLongPressGesture.minimumPressDuration = 1
        doneLongPressGesture.numberOfTapsRequired = 1
        
        todoTableView.addGestureRecognizer(todoLongPressGesture)
        doingTableView.addGestureRecognizer(doingLongPressGesture)
        doneTableView.addGestureRecognizer(doneLongPressGesture)
        
        todoLongPressGesture.delegate = self
        doingLongPressGesture.delegate = self
        doneLongPressGesture.delegate = self
    }
    
    private func switcher(task: Task, on view: UIView) {
        let switcher = TaskSwitchViewController()
        switcher.asPopover()
        switcher.sourceView(view: view)
        let useCase = TaskItemsUseCase(datasource: MemoryDataSource.shared)
        let viewmodel = TaskSwitchViewModel(useCase: useCase, task: task)
        switcher.viewmodel = viewmodel
        
        self.present(switcher, animated: true)
    }
    
    private func configureNavigationController() {
        if let navigationController = self.navigationController {
            let navigationBar = navigationController.navigationBar
            navigationBar.backgroundColor = UIColor.systemGray
            let rightAddButton = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                 action: #selector(tapNavigationAddButton))
            navigationItem.rightBarButtonItem = rightAddButton
            navigationItem.title = "Project Manager"
        }
    }
    
    private func configureView() {
        self.view.backgroundColor = UIColor.systemGray3
    }
    
    @objc
    private func tapNavigationAddButton() {
        let addTaskView = AddTaskViewController()
        addTaskView.modalPresentationStyle = .formSheet
        let useCase = TaskItemsUseCase(datasource: MemoryDataSource.shared)
        addTaskView.viewmodel = AddTaskViewModel(useCase: useCase)
        let navigation = UINavigationController(rootViewController: addTaskView)
        self.present(navigation, animated: true)
    }

    private func popOver(cell: UITableViewCell, item: Task) {
        let view = TaskSwitchViewController()
        view.sourceView(view: cell)
        self.present(view, animated: true)
    }
    
    private func createEditView(with item: TaskItemViewModel) -> UINavigationController {
        let editView = EditTaskViewController()
        let useCase = TaskItemsUseCase(datasource: MemoryDataSource.shared)
        editView.viewmodel = EditTaskViewModel(item: item, useCase: useCase)
        let navigation = UINavigationController(rootViewController: editView)
        return navigation
    }
}

extension ProjectManagerViewController {
    
    private func bindLongPress() {
        
        todoTableView.rx
            .methodInvoked(#selector(todoTableView.didLongPress))
            .withLatestFrom(self.todoTableView.rx.itemSelected)
            .subscribe(onNext: { index in
                if let cell = self.todoTableView.cellForRow(at: index) as? TaskCell,
                   let viewmodel = cell.viewmodel {
                    self.switcher(task: viewmodel.task, on: cell)
                }
            })
            .disposed(by: disposeBag)
        
        doingTableView.rx
            .methodInvoked(#selector(doingTableView.didLongPress))
            .withLatestFrom(doingTableView.rx.itemSelected)
            .subscribe(onNext: { index in
                if let cell = self.doingTableView.cellForRow(at: index) as? TaskCell,
                   let viewmodel = cell.viewmodel {
                    self.switcher(task: viewmodel.task, on: cell)
                }
            })
            .disposed(by: disposeBag)
        
        doneTableView.rx
            .methodInvoked(#selector(doneTableView.didLongPress))
            .withLatestFrom(doneTableView.rx.itemSelected)
            .subscribe(onNext: { index in
                if let cell = self.doneTableView.cellForRow(at: index) as? TaskCell,
                   let viewmodel = cell.viewmodel {
                    self.switcher(task: viewmodel.task, on: cell)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func cellAction() {
        self.todoTableView.rx
            .modelSelected(TaskItemViewModel.self)
            .subscribe(onNext: { item in
                let view = self.createEditView(with: item)
                self.present(view, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.doingTableView.rx
            .modelSelected(TaskItemViewModel.self)
            .subscribe(onNext: { item in
                let view = self.createEditView(with: item)
                self.present(view, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.doneTableView.rx
            .modelSelected(TaskItemViewModel.self)
            .subscribe(onNext: { item in
                let view = self.createEditView(with: item)
                self.present(view, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        guard let viewModel = self.viewModel else { return }
        
        let viewWillAppear = self.rx
            .methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in }
        
        let input = ProjectManagerViewModel.Input(update: viewWillAppear)
        let output = viewModel.transform(input: input)
        
        // MARK: Status View
        
        output.todoItems
            .map { String($0.count) }
            .bind(to: self.todoStatusView.taskCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.doingItems
            .map { String($0.count) }
            .bind(to: self.doingStatusView.taskCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.doneItems
            .map { String($0.count) }
            .bind(to: self.doneStatusView.taskCountLabel.rx.text)
            .disposed(by: disposeBag)

        // MARK: Table View Cell
        
        output.todoItems
            .bind(to: self.todoTableView.rx.items) { (tableview, index, item) in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: "task") as? TaskCell
                else { return TaskCell() }
                cell.viewmodel = item
                cell.setUp()
                return cell
            }
            .disposed(by: disposeBag)
        
        output.doingItems
            .bind(to: self.doingTableView.rx.items) { (tableview, index, item) in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: "task") as? TaskCell
                else { return TaskCell() }
                cell.viewmodel = item
                cell.setUp()
                return cell
            }
            .disposed(by: disposeBag)
        
        output.doneItems
            .bind(to: self.doneTableView.rx.items) { (tableview, index, item) in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: "task") as? TaskCell
                else { return TaskCell() }
                cell.viewmodel = item
                cell.setUp()
                return cell
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: Layout

extension ProjectManagerViewController {
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
        
        self.view.addSubview(wholeStackView)
        
        NSLayoutConstraint.activate([
            wholeStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            wholeStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            wholeStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wholeStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}

