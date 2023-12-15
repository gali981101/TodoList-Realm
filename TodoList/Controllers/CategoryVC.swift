//
//  CategoryVC.swift
//  TodoList
//
//  Created by Terry Jason on 2023/12/8.
//

import UIKit
import RealmSwift

class CategoryVC: SwipeVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var categoriesArray: Results<Category>?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    // MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        guard let category = categoriesArray?[indexPath.row] else { return }
        
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            print("類別刪除失敗...\(error.localizedDescription)")
        }
    }
    
}

// MARK: - SetUp

extension CategoryVC {
    
    private func setUp() {
        addCategoryButtonSet()
        searchBarDelegateSetUp()
        hideKeyboardWhenTappedAround()
        loadCategories()
    }
    
    private func addCategoryButtonSet() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "folder.fill.badge.plus"), style: .done, target: self, action: #selector(addCategory))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        addButton.tintColor = .label
        self.toolbarItems = [flexibleSpace, addButton]
    }
    
    private func searchBarDelegateSetUp() {
        searchBar.delegate = self
    }
    
}

// MARK: - @Objc Func

extension CategoryVC {
    
    @objc private func addCategory() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "新增待辦類別", message: "", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "取消", style: .destructive)
        let sureButton = UIAlertAction(title: "確定", style: .cancel) { [self] _ in
            guard textField.text != "" else { return }
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.dateCreated = Date()
            
            save(newCategory)
        }
        
        alert.addAction(sureButton)
        alert.addAction(cancelButton)
        
        alert.addTextField {
            $0.placeholder = "填寫類別名稱"
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

extension CategoryVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        categoriesArray = categoriesArray?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            Task { @MainActor in
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension CategoryVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let categories = categoriesArray else { return UITableViewCell() }
        let category = categories[indexPath.row]
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = category.name
        content.image = UIImage(systemName: "folder")
        
        cell.contentConfiguration = content
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension CategoryVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
}

// MARK: - Segue

extension CategoryVC {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            guard let destinationVC = segue.destination as? TodoListVC else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let categories = categoriesArray else { return }
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
}

// MARK: - Data Manupulation Func

extension CategoryVC {
    
    private func save(_ category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error Saving Category... \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    private func loadCategories() {
        categoriesArray = realm.objects(Category.self).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
}
