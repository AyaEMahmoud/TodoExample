//
//  ViewController.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 04/03/2024.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var todoItems: [Item] = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist", conformingTo: .propertyList)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell",
                                                 for: indexPath)
        
        cell.textLabel?.text = todoItems[indexPath.row].title
        cell.textLabel?.textColor = .black
        
        let item = todoItems[indexPath.row]
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        saveData()
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
            let newItem = Item(context: self.context)
            newItem.title = textField.text ?? ""
            newItem.done = false
            self.todoItems.append(newItem)
            self.saveData()
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Could not save data to coreData DB \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
       
        tableView.reloadData()
    }
}
