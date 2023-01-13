//
//  SugnUpViewController.swift
//  Stream
//
//  Created by Alisher Abdulin on 08.01.2023.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let logoImage: UIImageView = {
        let logo = UIImageView(image: UIImage(named: "stream-icon"))
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    private let mainText: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.text = "Welcome to Stream!"
        label.numberOfLines = 1
        return label
    }()
    
    private let subheader: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.text = "Create account and start your Stream journey"
        label.numberOfLines = 1
        return label
    }()
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter your name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter your email"
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter your password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        return field
    }()
    
    private let signUpButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor(red: 199.0/255.0, green: 44.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.setTitle("Create account", for: .normal)
        
        return button
    }()
    


    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
//        title = "Sign in"
        view.addSubview(mainText)
        view.addSubview(subheader)
        view.addSubview(logoImage)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let logoSize: CGFloat = 50
        logoImage.frame = CGRect(x: 20, y: 200, width: logoSize, height: logoSize)
        mainText.frame = CGRect(x: 20, y: Int(logoImage.bottom) + 20, width: Int(view.width)-40, height: 50)
        subheader.frame = CGRect(x: 20, y: Int(mainText.bottom), width: Int(view.width)-40, height: 50)
        nameField.frame = CGRect(x: 20, y: (subheader.bottom) + 10, width: view.width-40, height: 50)
        emailField.frame = CGRect(x: 20, y: (nameField.bottom) + 10, width: view.width-40, height: 50)
        passwordField.frame = CGRect(x: 20, y: (emailField.bottom) + 10, width: view.width-40, height: 50)
        signUpButton.frame = CGRect(x: 20, y: (passwordField.bottom) + 20, width: view.width-40, height: 50)
        
        
    }
    
    @objc func didTapSignUp() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let name = nameField.text, !name.isEmpty
        
        else {
            return
        }
        
        //create new user
        AuthManager.shared.signUp(email: email, password: password) { [weak self] success in //weak self is neeeded to prevent memory leaks
            if success {
                //update database
                let newUser = User(name: name, email: email, profilePictureRef: nil)
             
                DatabaseManager.shared.insert(user: newUser) { inserted in
                    guard inserted else {
                        return
                    }
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(name, forKey: "name")
                    DispatchQueue.main.async {
                        let vc = TabBarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }
                }
            } else {
                print("Failed to create account")
            }
        }
    }
    


}
