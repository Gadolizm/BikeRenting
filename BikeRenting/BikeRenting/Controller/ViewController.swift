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
    let initiatedNames = [(0,"Bike 1"),(1,"Bike 2"), (2,"Bike 3"), (3,"Bike 4") ,(4,"Bike 5"),(5,"Bike 6"),(6,"Bike 7"),(7,"Bike 8")]
//    let initiatedNames = ["Bike 1","Bike 2", "Bike 3", "Bike 4" ,"Bike 5","Bike 6","Bike 7","Bike 8"]

    var selectedBike : (id: Int, name: String)?
    
    
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
                initiatedNames.forEach{save(id: $0.0,name: $0.1)}

            }
            self.tableView.reloadData()

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
        
        if let selected = selectedBike {

            guard let rentingHours = Int(rentingHoursTextField.text ?? "") else { return }
            update(bike: BikeEntity(id: selected.id, name: selected.name, availability: false, rentFrom: getDate(hours: rentingHours).startingDate, rentTo: getDate(hours: rentingHours).endingDate))
            print(bikes[selectedBike?.id ?? 0])
        } else {
            alertNotSelectDisplay()
            
        }
        tableView.reloadData()
    }
    
    // MARK:- Methods
    
    
    func update(bike: BikeEntity)  {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bike")

        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Bike")
        let predicate = NSPredicate(format: "id = '\(bike.id)'")
        fetchRequest.predicate = predicate
        
//        fetchRequest.predicate = NSPredicate(format: "id = %@", bike.id)

        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 { // Atleast one was returned

                // In my case, I only updated the first item in results
                results?[0].setValue(bike.availability, forKey: "availability")
                results?[0].setValue(bike.rentFrom, forKey: "rentFrom")
                results?[0].setValue(bike.rentTo, forKey: "rentTo")


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

    func getDate(hours: Int)-> (startingDate: Date, endingDate: Date) {
        let startDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:ss"
//        let stringDate = timeFormatter.string(from: time)
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .hour, value: hours, to: startDate) else { return (Date(),Date()) }
//        let endingDate = timeFormatter.string(from: endDate)
        return (startDate,endDate)
    }
    
    func alertNotSelectDisplay()  {
        let alert = UIAlertController(title: "Alert", message: "Select Bike before pressing save please", preferredStyle: .alert)
        
        
        
        let okAction = UIAlertAction(title: "Ok", style: .default)

        
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func alertNotAvailableDisplay()  {
        let alert = UIAlertController(title: "Alert", message: "Select available bike please", preferredStyle: .alert)
        
        
        
        let okAction = UIAlertAction(title: "Ok", style: .default)

        
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func save(id: Int, name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Bike", in: managedContext)!
        
        let bike = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        bike.setValue(id, forKeyPath: "id")
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

        if currentCell.backgroundColor == #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) {
            alertNotAvailableDisplay()
        }
        selectedBike = (Int(indexPath!.row), currentCell.textLabel?.text ?? "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bike = bikes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        cell.textLabel?.text = bike.value(forKeyPath: "name") as? String
        guard let availability = bike.value(forKeyPath: "availability") as? Bool else { return  cell}
        if  availability == false {
            cell.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            cell.selectionStyle = .none
        }
        return cell
    }
}




