//
//  CategoryTableViewController.swift
//  TodoeyApp
//
//  Created by Aya Mahmoud on 16/03/2024.
//

import UIKit
import CoreData
import RealmSwift

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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoris?[indexPath.row].name ?? "No categories added yet"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoris?.count ?? 1
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
