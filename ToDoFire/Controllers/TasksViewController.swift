//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by Егор Шкарин on 15.06.2021.
//

import UIKit
import Firebase
class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var user: User!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Firebase.Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) {[weak self] snapshot in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        }
    }
    
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Новая задача", message: "Добавте новую задачу", preferredStyle: .alert)
        ac.addTextField()
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let tf = ac.textFields?.first, tf.text != "" else {return}
            let task = Task(title: tf.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.makeDictionary())
            
        }
        let cancel = UIAlertAction(title: "Закрыть", style: .default, handler: nil)
        
        ac.addAction(save)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
    }
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch  {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension TasksViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.isCompleted
        cell.textLabel?.text = taskTitle
        toggleCompletion(cell, isCompleted: isCompleted)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        let task = tasks[indexPath.row]
        let isCompleted = !task.isCompleted
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])
    }
}
