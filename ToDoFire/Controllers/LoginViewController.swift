//
//  ViewController.swift
//  ToDoFire
//
//  Created by Егор Шкарин on 15.06.2021.
//

import UIKit
import Firebase
class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var ref: FirebaseDatabase.DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FirebaseDatabase.Database.database().reference(withPath: "users")
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        warnLabel.alpha = 0
        FirebaseAuth.Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        }
        emailTF.delegate = self
        passwordTF.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if error == nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            self?.displayWarningLabel(withText: "No such user")
        }
    }
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            guard error == nil, user != nil else { return }
            let userRef = self?.ref?.child((user?.user.uid)!)
            userRef?.setValue(["email": user?.user.email])
        }
    }
    
    func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: [.curveEaseInOut]) { [weak self] in
            self?.warnLabel.alpha = 1
        } completion: {[weak self] complete in
            self?.warnLabel.alpha = 0
        }

    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
        }
    }
    
    @objc func keyBoardWillHide() {
        if self.view.frame.origin.y != 0 {
              self.view.frame.origin.y = 0
          }
    }
}

extension LoginViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
