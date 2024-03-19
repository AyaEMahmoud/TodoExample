//
//  ViewController.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 04/03/2024.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist", conformingTo: .propertyList)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell",
                                                 for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = todoItems?[indexPath.row].title
            cell.accessoryType = item.done ? .checkmark : .none

        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // update data in dealm
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
                //delete data in realm
//                realm.delete(item)
            } catch {
                print("Could not update data in realm \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new todo item
    
    @IBAction func AddButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todo Item",
                                      message: "",
                                      preferredStyle: .alert)
        
        alert.addTextField { todoTextField in
            todoTextField.placeholder = "Create New Item"
            textField = todoTextField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        var newItem = Item()
                        newItem.title = textField.text ?? ""
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items \(error)")
                }
            }
            self.tableView.reloadData()
           
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: R in CRUD operations to Realm DB
    
    
    //Read
    func loadData() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
}

// MARK: Search bar Delegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdAt", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            
            // Grapping the main queue to dismiss kb even if background tasks are still being completed.
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

