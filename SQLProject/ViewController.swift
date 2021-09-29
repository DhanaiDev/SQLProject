//
//  ViewController.swift
//  SQLProject
//
//  Created by dhanasekaran on 24/09/21.
//

import UIKit

class ViewController: UIViewController {
    
    let userTable = UserTable()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SQLTableViewCell.self, forCellReuseIdentifier: SQLTableViewCell.cellReuseIdentifier)
        
        return tableView
    }()
    
    private lazy var nameTextInput: UITextField = {
        let inputView = UITextField()
        inputView.placeholder = "Add Name to SQLDB"
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.addTarget(self, action: #selector(self.getTextField(_:)), for: .editingChanged)
        
        return inputView
    }()
    
    private lazy var emailTextInput: UITextField = {
        let inputView = UITextField()
        inputView.placeholder = "Add Email to SQLDB"
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.addTarget(self, action: #selector(self.getTextField(_:)), for: .editingChanged)
        
        return inputView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.addModel), for: .touchUpInside)
        button.setTitle("Add", for: .normal)
        button.backgroundColor = view.tintColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var textView: UIView = {
        let textView = UIView.init()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.addSubview(nameTextInput)
        textView.addSubview(emailTextInput)
        textView.addSubview(button)
        
        NSLayoutConstraint.activate([
            
            nameTextInput.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 20),
            nameTextInput.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -20),
            nameTextInput.topAnchor.constraint(lessThanOrEqualTo: textView.topAnchor, constant: 5),
            nameTextInput.bottomAnchor.constraint(equalTo: emailTextInput.topAnchor, constant: 5),
            
            emailTextInput.leadingAnchor.constraint(equalTo: nameTextInput.leadingAnchor),
            emailTextInput.trailingAnchor.constraint(equalTo: nameTextInput.trailingAnchor),
            emailTextInput.bottomAnchor.constraint(greaterThanOrEqualTo: textView.bottomAnchor, constant: -5),
            
            button.widthAnchor.constraint(equalTo: textView.widthAnchor, multiplier: 0.3),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
        ])
        
        return textView
    }()
    
    private var users: [User] {
        guard let db_users = try? userTable.getUsers() else { return [] }
        
        return db_users
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureView()
        disableButton()
    }
    
    private func configureView() {
        let vStackView = UIView.init()
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addSubview(textView)
        vStackView.addSubview(tableView)
        

        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 100),
            textView.topAnchor.constraint(equalTo: vStackView.topAnchor),
            
            tableView.topAnchor.constraint(equalTo: textView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: vStackView.bottomAnchor),
        ])
        
        view.addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            
            vStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            vStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc func addModel() {
        guard let name = nameTextInput.text, name.isEmpty == false, let email = emailTextInput.text, email.isEmpty == false  else { return }
        
        nameTextInput.text = nil
        emailTextInput.text = nil
        
        if let _ = try? userTable.insert(user: User.init(id: 0, name: name, emailID: email)) {
            tableViewReload()
        } else {
            print("Failed to Index")
        }
    }
    
    private func tableViewReload() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            nameTextInput.becomeFirstResponder()
        }
    }
    
    @objc func getTextField(_ sender: UITextField) {
        if let name = nameTextInput.text, name.isEmpty == false, let email = emailTextInput.text, email.isEmpty == false {
            enableButton()
        } else {
            disableButton()
        }
    }
    
    func enableButton() {
        button.alpha = 1
        button.isEnabled = true
    }
    
    func disableButton() {
        button.alpha = 0.5
        button.isEnabled = false
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SQLTableViewCell.cellReuseIdentifier, for: indexPath) as! SQLTableViewCell
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(user.id) \(user.name)"
        cell.detailTextLabel?.text = "Edit"
        cell.selectionStyle = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let selectedUser = users[indexPath.row]
        if let _ = try? userTable.removeUser(selectedUser) {
            print("User Deleted Success Fully")
            tableViewReload()
        } else {
            print("Unable to Delete SQL Error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        func promptMessage() {
            let prompt = UIAlertController(title: "Enter Proper Name", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                prompt.dismiss(animated: true, completion: nil)
            }
            prompt.addAction(cancelAction)
            self.present(prompt, animated: true, completion: nil)
        }
        
        let user = users[indexPath.row]
        
        let ac = UIAlertController(title: "Update Name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].text = user.name

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            if let newValue = ac.textFields?[0].text, newValue != user.name, newValue.isEmpty == false {
                ac.dismiss(animated: true) {
                    if let _ = try? self.userTable.updateUser(user, newUserName: newValue) {
                        print("User Updated Success Fully")
                        self.tableViewReload()
                    } else {
                        print("Unable to Update SQL")
                    }
                }
            } else {
                ac.dismiss(animated: true) {
                    promptMessage()
                }
            }
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Swipe to Delete the row in SQL DB"
    }
}

extension UITableViewCell {
    static var cellReuseIdentifier: String {
        return "reuseID"
    }
}


class SQLTableViewCell: UITableViewCell
{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

