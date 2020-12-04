//
//  ViewController.swift
//  BikeRenting
//
//  Created by Gado on 04/12/2020.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalIncomeTextField: UILabel!
    @IBOutlet weak var rentingHoursTextField: UITextField!
    
    // MARK:- Properties
    
    var bikes: [NSManagedObject] = []
    let initiatedNames = ["Bike 1","Bike 2", "Bike 3", "Bike 4" ,"Bike 5","Bike 6","Bike 7","Bike 8"]
    var selectedBike = ""
    
    
    // MARK:- Override Functions
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bike")
        
        //3
        do {
            bikes = try managedContext.fetch(fetchRequest)
            if bikes.count == 0 {
                initiatedNames.forEach{save(name: $0)}
                self.tableView.reloadData()

            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    // MARK:- Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if selectedBike == "" {
            alertDisplay()
        } else {
            
        }
    }
    
    // MARK:- Methods
    
    
    func update(name: String)  {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alert")

        fetchRequest.predicate = NSPredicate(format: "name = %@", name)

        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 { // Atleast one was returned

                // In my case, I only updated the first item in results
                results?[0].setValue("yourValueToBeSet", forKey: "yourCoreDataAttribute")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }

        do {
            try context.save()
           }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
        
       
  
        
    }
    
    func alertDisplay()  {
        let alert = UIAlertController(title: "Alert",
                                      message: "Select Bike before pressing save please",
                                      preferredStyle: .alert)
        
        
        
        let okAction = UIAlertAction(title: "Ok", style: .default)

        
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Bike", in: managedContext)!
        
        let bike = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        bike.setValue(name, forKeyPath: "name")
        
        // 4
        do {
            try managedContext.save()
            bikes.append(bike)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bikes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example

        let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell


        selectedBike = currentCell.textLabel?.text ?? ""
        print(selectedBike)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bike = bikes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        cell.textLabel?.text = bike.value(forKeyPath: "name") as? String
        return cell
    }
}




