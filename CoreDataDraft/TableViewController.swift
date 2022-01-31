//
//  TableViewController.swift
//  CoreDataDraft
//
//  Created by Alex Son on 07.01.22.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
   // var tasks: [String] = []
   // 2. Далее меняем на Tasks. Если выдают ошибку идем в Xcode - Preferences - Locations - Derived Data  и удаляем папку Derived Data и удаляем строку с кодом self.tasks.insert(newTask, at: 0)
    var tasks: [Tasks] = []
    
    @IBAction func plusTasks(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New task", message: "Add new task", preferredStyle: .alert)
        let saveTask = UIAlertAction(title: "Save", style: .default) { action in
            let tf = alertController.textFields?.first
            if let newTask = tf?.text {
          //      self.tasks.insert(newTask, at: 0)
                self.saveTask(withTitle: newTask)
                self.tableView.reloadData()
            }
        }
    
        alertController.addTextField { _ in }
        
        let canceledAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(saveTask)
        alertController.addAction(canceledAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 3. Создадим метод который, будет записывать данные в Coredata
    func saveTask(withTitle title: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Теперь нам нужно добраться до нашего viewContext (который нах-ся в AppDelegate)
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context) else { return }
        
        let taskObject = Tasks(entity: entity, insertInto: context)
        taskObject.title = title
        
        // 4. Теперь когда мы создали объект в нашем context - наш context изменился и теперь нам нужно попробовать его записать, поэтому мы используем do catch block
        do {
            try context.save()
            // 7. Добавим след. команду для отображения информации из БД в нашем приложении.
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    // 5. Теперь можем обратиться к тому что мы записали в Core data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Теперь нам нужно снова добравться до нашего context, для этого мы можем просто скопировать 2 строки сверху
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // и нам нужно написать запрос, по которому мы будем получать наши данные
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.delete
    }
    
    override  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.endUpdates()
        }
    }
}




// 1. Создадим модель Coredata, теперь нам нужно создать сущность (Add Entity) называем ее Tasks. Tasks - это тот же самый класс, который мы создавали в Realm. Нажимаем + и создаем Title.
