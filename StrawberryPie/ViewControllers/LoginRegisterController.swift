//
//  ViewController.swift
//  StrawberryPie
//
//  Created by Markus Saronsalo on 19/11/2019, modified on 27/11/2019.
//  Copyright © 2019 Team Työkkäri. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class LoginRegisterController: UIViewController, UITextFieldDelegate {
  
  var signUpFormEnabled = Bool()
  let messageLabel = UILabel()
  let changeFormButton = UIButton(type: .roundedRect)
  let loginButton = UIButton(type: .roundedRect)
  let signUpButton = UIButton(type: .roundedRect)
  let errorLabel = UILabel()
  let usernameField = UITextField()
  let firstnameField = UITextField()
  let lastnameField = UITextField()
  let userinfoField = UITextField()
  let userpasswordField = UITextField()
  let userpwagainField = UITextField()
  
  var realm: Realm!
  var notificationToken: NotificationToken?
  var user: SyncUser?
  let main = UIStoryboard(name: "Main", bundle: nil)
  let thisUser = User()
  
  // Tänne pusketaan data --> Vaihda johonkin fiksumpaan
  private var tableSource = [] as [ChatMessage]
  
  //Log user
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    usernameField.delegate = self
    userpasswordField.delegate = self
    userinfoField.delegate = self
    userpwagainField.delegate = self
    firstnameField.delegate = self
    lastnameField.delegate = self
    
    usernameField.isHidden = false
    userpasswordField.isHidden = false
    userinfoField.isHidden = true
    userpwagainField.isHidden = true
    firstnameField.isHidden = true
    lastnameField.isHidden = true
    loginButton.isHidden = true
    signUpButton.isHidden = true
    changeFormButton.isHidden = false
    
    self.signUpFormEnabled = true
    self.switchForm()
    
    // Container, can be used for additional information on the screen, is built programmatically
    let container = UIStackView()
    
    messageLabel.numberOfLines = 0
    messageLabel.text = "Please enter your login information"
    container.addArrangedSubview(messageLabel)
    container.translatesAutoresizingMaskIntoConstraints = false
    container.axis = .vertical
    container.alignment = .fill
    container.spacing = 16.0
    view.addSubview(container)
    
    // Create Register / Login Form
    // Styling etc. could be moved to another separate styling file
    // --------------------------------------
    userpwagainField.isSecureTextEntry = true
    userpasswordField.isSecureTextEntry = true
    userinfoField.frame.size.height = 100
    usernameField.placeholder = "Username"
    usernameField.borderStyle = .roundedRect
    usernameField.autocapitalizationType = .none
    container.addArrangedSubview(usernameField)
    firstnameField.placeholder = "First name"
    firstnameField.borderStyle = .roundedRect
    container.addArrangedSubview(firstnameField)
    lastnameField.placeholder = "Last name"
    lastnameField.borderStyle = .roundedRect
    container.addArrangedSubview(lastnameField)
    userinfoField.placeholder = "Info"
    userinfoField.borderStyle = .roundedRect
    container.addArrangedSubview(userinfoField)
    
    userpasswordField.placeholder = "Password"
    userpasswordField.borderStyle = .roundedRect
    userpasswordField.autocapitalizationType = .none
    container.addArrangedSubview(userpasswordField)
    userpasswordField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: lower; required: digit; max-consecutive: 2; minlenght: 8;")
    userpwagainField.placeholder = "Password again"
    userpwagainField.borderStyle = .roundedRect
    userpwagainField.autocapitalizationType = .none
    container.addArrangedSubview(userpwagainField)
    // Buttons
    loginButton.setTitle("Login", for: .normal)
    loginButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    container.addArrangedSubview(loginButton)
    signUpButton.setTitle("Sign up", for: .normal)
    signUpButton.addTarget(self, action: #selector(createUser), for: .touchUpInside)
    container.addArrangedSubview(signUpButton)
    changeFormButton.addTarget(self, action: #selector(switchForm),
                               for: .touchUpInside)
    container.addArrangedSubview(changeFormButton)
    // Container's location on the screen
    let guide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      container.centerXAnchor.constraint(equalTo: guide.centerXAnchor, constant: 0),
      container.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: -100),
      
      ])
    
    
  }
  // NOT IN USE, might be used later
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
  }
  
  // LOGIN FUNCTION, ALL THE LOGIC NOT IMPLEMENTED, WILL BE SUBJECT TO CHANGE
  func logIn(_ username: String,_ password: String,_ register: Bool) {
    if usernameField.text == "" {
      self.present(customAlert(title: "uname", reason: "Missing username"), animated: true, completion: nil)
    } else if userpasswordField.text == "" {
      self.present(customAlert(title: "upw", reason: "Missing password"),
                   animated: true, completion: nil)
    } else {
      // USER FROM REALM IS AVAILABLE BEFORE IF-statement so doesnt work, FIX PLS
      loginRealm(username, password, register)
    }
    
  }
  
  // To reduce clutter calling alert
  func customAlert(title: String, reason: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: reason, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    return alert
    
  }
  
  
  func loginRealm(_ username: String,_ password: String,_ register: Bool){
    // Yritä kirjautua sisään --> Vaihda kovakoodatut tunnarit pois
    let loggedIn: UITabBarController? = main.instantiateViewController(withIdentifier: "LoggedInTabBar") as? UITabBarController
    SyncUser.logIn(with: .usernamePassword(username: username, password: password, register: false), server: Constants.AUTH_URL) { user, error in
      if let user = user {
        RealmDB.sharedInstance.user?.logOut()
        // Onnistunut kirjautuminen
        // Lähetetään permission realmille -> read/write oikeudet käytössä olevalle palvelimelle. realmURL: Constants.REALM_URL --> Katso Constants.swift
        let permission = SyncPermission(realmPath: Constants.REALM_URL.absoluteString, username: "\(username)", accessLevel: .write)
        user.apply(permission, callback: { (error) in
          if error != nil {
            print(error?.localizedDescription ?? "No error")
          } else {
            print("success")
          }
        })
        self.user = user
        let admin = user.isAdmin
        print(admin)
        RealmDB.sharedInstance.user = self.user
        // Leivotaan realmia varten asetukset. realmURL: Constants.REALM_URL --> Katso Constants.swift
        let config = user.configuration(realmURL: Constants.REALM_URL, fullSynchronization: true)
        self.realm = try! Realm(configuration: config)
        RealmDB.sharedInstance.realm = self.realm
        print("Realm connection has been setup")
        print("Changing navigators")
        self.present(loggedIn!, animated:true, completion: nil)
      } else if let error = error {
        print("Login error: \(error)")
        self.present(self.customAlert(title: "Login", reason: "Wrong login"), animated: true, completion: nil)
      }
    }
    
  }
  
  
  // SIGNUP FUNCTION EARLY VERSION, SUBJECT TO CHANGE
  func signUp(_ username: String, _ password: String, _ register: Bool) -> User {
    let loggedIn: UITabBarController? = main.instantiateViewController(withIdentifier: "LoggedInTabBar") as? UITabBarController
    if usernameField.text == "" {
      self.present(customAlert(title: "uname", reason: "Missing username"), animated: true, completion: nil)
    } else if userpasswordField.text == "" {
      self.present(customAlert(title: "upw", reason: "Missing password"),
                   animated: true, completion: nil)
    } else if userpasswordField.text != "" && userpwagainField.text == "" {
      self.present(customAlert(title: "upw", reason: "Please confirm password"),
                   animated: true, completion: nil)
    } else if usernameField.text != "" && userpasswordField.text != "" && userpwagainField.text != "" {
      
      
      SyncUser.logIn(with: .usernamePassword(username: username, password: password, register: true), server: Constants.AUTH_URL) { user, error in
        if let user = user {
          
          RealmDB.sharedInstance.user?.logOut()
          // Onnistunut kirjautuminen
          // Lähetetään permission realmille -> read/write oikeudet käytössä olevalle palvelimelle. realmURL: Constants.REALM_URL --> Katso Constants.swift
          let permission = SyncPermission(realmPath: Constants.REALM_URL.absoluteString, username: "\(username)", accessLevel: .write)
          user.apply(permission, callback: { (error) in
            if error != nil {
              print("Something went wrong: \(String(describing: error?.localizedDescription))")
            } else {
              print("success")
            }
          })
          self.user = user
          RealmDB.sharedInstance.user = self.user
          // Leivotaan realmia varten asetukset. realmURL: Constants.REALM_URL --> Katso Constants.swift
          let config = user.configuration(realmURL: Constants.REALM_URL, fullSynchronization: true)
          self.realm = try! Realm(configuration: config)
          RealmDB.sharedInstance.realm = self.realm
          guard let userIdentity = self.user?.identity else {
            self.present(self.customAlert(title: "Register Error!", reason: "userIdentity not found"), animated: true, completion: nil)
            return }
          self.thisUser.userID = userIdentity
          self.thisUser.userName = username
          print("Realm connection has been setup")
          print("Changing navigators")
          self.present(loggedIn!, animated:true, completion: nil)
        } else if let error = error {
          print("Signup error!: \(error)")
          self.present(self.customAlert(title: "Signup", reason: "Something went wrong"), animated: true, completion: nil)
        }
        
        
        
        
      }
     
      
     
    }
    
    return thisUser
  }
  func signIn() {
    logIn(username ?? "", password ?? "", false)
  }
  func createUser() {
    signUp(username ?? "", password ?? "", true)
    
  }
  // Change between login / register
  func switchForm() {
    self.changeFormButton.isHidden = false
    if signUpFormEnabled {
      // LOGIN Form chosen -> Show login fields
      signUpFormEnabled = false
      self.messageLabel.text = "Please enter your login information"
      self.usernameField.isHidden = false
      self.firstnameField.isHidden = true
      self.lastnameField.isHidden = true
      self.userpasswordField.isHidden = false
      self.userpwagainField.isHidden = true
      self.userinfoField.isHidden = true
      self.loginButton.isHidden = false
      self.signUpButton.isHidden = true
      changeFormButton.setTitle("Sign up instead", for: .normal)
    } else if
      !signUpFormEnabled {
      signUpFormEnabled = true
      self.messageLabel.text = "Please fill out the registration form"
      // SIGNUP Form chosen -> Show signup fields
      self.usernameField.isHidden = false
      self.userpasswordField.isHidden = false
      self.userpwagainField.isHidden = false
      self.firstnameField.isHidden = false
      self.lastnameField.isHidden = false
      self.userinfoField.isHidden = false
      self.loginButton.isHidden = true
      self.signUpButton.isHidden = false
      changeFormButton.setTitle("Already have an account? Login instead", for: .normal)
    }
  
    
    // Getters
  }
  var firstname: String? {
    get {
      return firstnameField.text
    }
  }
  var lastname: String? {
    get {
      return lastnameField.text
    }
  }
  var info: String? {
    get {
      return userinfoField.text
    }
  }
  var username: String? {
    get {
      return usernameField.text
    }
  }
  var password: String? {
    get {
      return userpasswordField.text
    }
  }
  // NOT USED but might be useful, can set and get bool
  var userDef: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "userExists")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "userExists")
    }
  }
}


