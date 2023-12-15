//
//  SwipeVC.swift
//  TodoList
//
//  Created by Terry Jason on 2023/12/14.
//

import UIKit
import SwipeCellKit

class SwipeVC: UITableViewController {
    
    var cell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 50.0
    }
    
    func updateModel(at indexPath: IndexPath) {}
    
}

// MARK: - UITableViewDataSource

extension SwipeVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
}

// MARK: - SwipeTableViewCellDelegate

extension SwipeVC: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [self] action, indexPath in
            updateModel(at: indexPath)
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}







