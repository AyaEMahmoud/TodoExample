//
//  ViewController.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 04/03/2024.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Nav bar is nil at this time point")}

        if let bgColor = selectedCategory?.bgColor {
            if let navBarColor = UIColor(hexString: bgColor) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
            }
        }
        title = selectedCategory?.name ?? ""

    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = todoItems?[indexPath.row].title
            cell.accessoryType = item.done ? .checkmark : .none
            
            cell.backgroundColor = UIColor(hexString: selectedCategory?.bgColor ?? "000000")?
                .darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor ?? .black, returnFlat: true)

        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // update data in dealm
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
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
                        let newItem = Item()
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
    
    // MARK: CRUD operations to Realm DB
    
    //Read
    func loadData() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //Delete
    override func deleteModel(at indexPath: IndexPath) {
        
        super.deleteModel(at: indexPath)
        
        if let deletedCategory = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(deletedCategory)
                }
            } catch {
                print("Could not delete category \(error)")
            }
        }
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

