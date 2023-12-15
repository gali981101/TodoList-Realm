//
//  ViewController.swift
//  TodoList
//
//  Created by Terry Jason on 2023/12/4.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TodoListVC: SwipeVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedCategory?.name
        setUp()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    // MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        guard let item = todoItems?[indexPath.row] else { return }
        
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("項目刪除失敗...\(error.localizedDescription)")
        }
    }
    
}

// MARK: - SetUp

extension TodoListVC {
    
    private func setUp() {
        addButtonSet()
        searchBarDelegateSetUp()
        tableViewDragDelegate()
        hideKeyboardWhenTappedAround()
    }
    
    private func addButtonSet() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addToDo))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        addButton.tintColor = .label
        self.toolbarItems = [flexibleSpace, addButton]
    }
    
    private func searchBarDelegateSetUp() {
        searchBar.delegate = self
    }
    
    private func tableViewDragDelegate() {
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
    }
    
}

// MARK: - @Objc Func

extension TodoListVC {
    
    @objc private func addToDo() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "新增待辦事項", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "取消", style: .destructive)
        let sure = UIAlertAction(title: "確定", style: .cancel) { [self] _ in
            guard textField.text != "" else { return }
            guard let currentCategory = selectedCategory else { return }
            
            do {
                try realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }
            } catch {
                print("Realm Write Error \(error.localizedDescription)")
            }
            
            tableView.reloadData()
        }
        
        alert.addAction(sure)
        alert.addAction(cancel)
        
        alert.addTextField {
            $0.placeholder = "寫些什麼..."
            textField = $0
        }
        
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func dismissAlert() {
        self.dismiss(animated: true)
    }
    
}

// MARK: - UISearchBarDelegate

extension TodoListVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        todoItems = todoItems?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            Task { @MainActor in
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension TodoListVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = todoItems else { return UITableViewCell() }
        let item = items[indexPath.row]
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        cell.tintColor = .label
        cell.contentConfiguration = content
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TodoListVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = todoItems?[indexPath.row] else { return }
        
        do {
            try realm.write {
                item.done.toggle()
            }
        } catch {
            print("Error saving done status, \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDragDelegate

extension TodoListVC: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = todoItems?[indexPath.row]
        return [dragItem]
    }
    
}

// MARK: - Data Manupulation Func

extension TodoListVC {
    
    private func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
}




