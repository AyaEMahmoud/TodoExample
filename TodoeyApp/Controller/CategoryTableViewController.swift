//
//  CategoryTableViewController.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 16/03/2024.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryTableViewController: UITableViewController {

    let realm = try! Realm()
    var categoris: Results<Category>?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    // MARK: - Table View DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categoris?[indexPath.row].name ?? "No categories added yet"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoris?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categoris?[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textFeild = UITextField()
        
        let alert = UIAlertController(title: "Add New Category",
                                      message: "", preferredStyle: .alert)
        
        alert.addTextField { categoryTextFeild in
            categoryTextFeild.placeholder = "Category Name"
            textFeild = categoryTextFeild
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let category = Category()
            category.name = textFeild.text ?? ""
            self.save(category: category)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Could not persist data to perminant stoage \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
       
        categoris = realm.objects(Category.self)
      
        tableView.reloadData()
    }
}


// MARK: - SwipeTableViewCellDelegate

extension CategoryTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            if let deletedCategory = self.categoris?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(deletedCategory)
                    }
                } catch {
                    print("Could not delete category \(error)")
                }
                tableView.reloadData()
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
}
