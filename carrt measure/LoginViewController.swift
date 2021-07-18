//
//  LoginViewController.swift
//  Carrt Measure
//
//  Created by Varaha Maithreya on 7/5/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var signInButton : UIButton!
    
    @IBOutlet var signUpButton : UIButton!
    @IBOutlet var errorLabel: UILabel!
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Create a view that will automatically lay out the other controls.
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .fill
        container.spacing = 16.0
        view.addSubview(container)

        
        // Configure the activity indicator.
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        // Set the layout constraints of the container view and the activity indicator.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // This pins the container view to the top and stretches it to fill the parent
            // view horizontally.
            container.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            // The activity indicator is centered over the rest of the view.
            activityIndicator.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
            ])

        errorLabel.text = ""
        // Error messages will be set on the errorLabel.
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .red
        //container.addArrangedSubview(errorLabel)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            errorLabel.text = ""
        } else {
            activityIndicator.stopAnimating()
        }
        emailField.isEnabled = !loading
        passwordField.isEnabled = !loading
        signInButton.isEnabled = !loading
        //signUpButton.isEnabled = !loading
    }

    @IBAction  func signUp(_ sender: UIButton) {
        setLoading(true)
        let email = (emailField.text) ?? ""
        let password = (passwordField.text)
        app.emailPasswordAuth.registerUser(email: email, password: password!, completion: { [weak self](error) in
            
            DispatchQueue.main.async {
                self!.setLoading(false)
                guard error == nil else {
                    print("Signup failed: \(error!)")
                    self!.errorLabel.text = "Signup failed: \(error!.localizedDescription)"
                    return
                }
                print("Signup successful!")

                
                self!.errorLabel.text = "Signup successful! Signing in..."
                self!.navigationController!.pushViewController(ManageTeamViewController(), animated: true)
                //self!.signIn()
            }
        })
    }


    @IBAction  func signIn(_ sender: UIButton) {
        let email = (emailField.text)
        let password = (passwordField.text)
        print("Log in as user: \(email!)")
        setLoading(true)
       
        app.login(credentials: Credentials.emailPassword(email: email!, password: password!)) { [weak self](result) in
            
            DispatchQueue.main.async {
                self!.setLoading(false)
                switch result {
                case .failure(let error):
                    
                    print("Login failed: \(error)")
                    self!.errorLabel.text = "Login failed: \(error.localizedDescription)"
                    return
                case .success(let user):
                    print("\(user)  Login succeeded!")
                    
                    
                    
                   

                    self!.navigationController!.pushViewController(ManageTeamViewController(), animated: true)
                    
                    
                    
//
                            }
                        }
        }
                }
}
