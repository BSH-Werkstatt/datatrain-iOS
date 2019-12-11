//
//  LoginController.swift
//  BSH
//
//  Created by Emil Oldenburg on 23.06.19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import UIKit
import SwaggerClient
import CUU
import FirebaseAnalytics

class LoginController: CUUViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: BshCustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let email = UserDefaults.standard.string(forKey: "user-email") else {
            return
        }
        emailField.text = email
        
        self.hideKeyboard()
    }


    @IBAction func loginPrimaryAction(_ sender: Any) {
        self.login()
        CUU.seed(name: "Login: Enter Email")
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        self.login()
        CUU.seed(name: "Login: Login Button pressed")
    }

    private func login(){
        guard let email = emailField.text else {
            showLoginError("Please fill in a correct e-mail address.")
            return
        }
        guard let password = passwordField.text else {
            showLoginError("Please fill the password")
            return
        }
         userLogin(email: email,password: password)
//        if isValidEmail(testStr: email) {
//            userLogin(email: email,password: password)
//        } else {
//            showLoginError("The e-mail address format is invalid.")
//        }
    }


  /*  public func userLogin(email: String, password : String) {
        var isAuthenticated = NetworkManager.shared.authenticateUserWithServer(username: email,password: password);
        
        /*print(isAuthenticated);
        print("Inside login controller");
        if(isAuthenticated) {
            UserDefaults.standard.set(true, forKey: "loggedIn")
            UserDefaults.standard.set(emailField.text, forKey: "user-id")
//            UserDefaults.standard.set(emailField.text, forKey: "user-email")
            Analytics.logEvent(AnalyticsEventLogin, parameters: ["logged-in": true])
            Switcher.updateRootVC()
        } else {
            self.showLoginError("The login failed. please check your credentials.");
        }*/
//        DefaultAPI.getUserByEmail(email: email, completion: { (user, error) in
//        guard let user = user else {
//            self.showLoginError("The login failed. Your e-mail address might not be registered." + (error?.localizedDescription ?? "Error"))
//            return
//        }
//            UserDefaults.standard.set(true, forKey: "loggedIn")
//            UserDefaults.standard.set(user._id, forKey: "user-id")
//            UserDefaults.standard.set(user.email, forKey: "user-email")
//            Analytics.logEvent(AnalyticsEventLogin, parameters: ["logged-in": true])
//            Switcher.updateRootVC()
//        })


    }*/
    public func userLogin(email: String, password : String) {
    //        let isAuthenticated = NetworkManager.shared.authenticateUserWithServer(username: email,password: password);
    //        print(isAuthenticated);
    //        print("Inside login controller");
    //        if(isAuthenticated) {
    //            UserDefaults.standard.set(true, forKey: "loggedIn")
    //            UserDefaults.standard.set(emailField.text, forKey: "user-id")
    ////            UserDefaults.standard.set(emailField.text, forKey: "user-email")
    //            Analytics.logEvent(AnalyticsEventLogin, parameters: ["logged-in": true])
    //            Switcher.updateRootVC()
    //        } else {
    //            self.showLoginError("The login failed. please check your credentials.");
    //        }
    //        DefaultAPI.getUserByEmail(email: email, completion: { (user, error) in
    //        guard let user = user else {
    //            self.showLoginError("The login failed. Your e-mail address might not be registered." + (error?.localizedDescription ?? "Error"))
    //            return
    //        }
    //            UserDefaults.standard.set(true, forKey: "loggedIn")
    //            UserDefaults.standard.set(user._id, forKey: "user-id")
    //            UserDefaults.standard.set(user.email, forKey: "user-email")
    //            Analytics.logEvent(AnalyticsEventLogin, parameters: ["logged-in": true])
    //            Switcher.updateRootVC()
    //        })
      NetworkManager.shared.userCredentials = UserCredentials(name: email, password: password)
             //   NetworkManager.shared.authenticateUserWithServer(username: email,password: password);
            NetworkManager.shared.authenticateUser(requestName: API_Names.LoginApi, requestType: RequestType.GET, urlParameters: nil, bodyParameters: nil, completion: { (resultDict) in
                print(resultDict)
                
                if(resultDict){
                     UserDefaults.standard.set(email, forKey: "user-id")
                    UserDefaults.standard.set(email, forKey: "user-email")
                    UserDefaults.standard.set(true, forKey: "loggedIn")
                    Analytics.logEvent(AnalyticsEventLogin, parameters: ["logged-in": true])
                     Switcher.updateRootVC()
                }
                else{
                    self.showLoginError("The login failed. please check your credentials.");
                }
              //  print(resultDict)
    //            if (resultDict["error"] == nil) && resultDict["errorMessages"] == nil{//success
    //       UserDefaults.standard.set(true, forKey: "loggedIn")
    //                           UserDefaults.standard.set(email, forKey: "user-id")
    //                           UserDefaults.standard.set(email, forKey: "user-email")
    //                          Analytics.logEvent(AnalyticsEventLogin, parameters: ["logged-in": true])
    //                            Switcher.updateRootVC()
    //            }
    //            else{
    //                self.showLoginError("The login failed. please check your credentials.");
    //               // self.loginPresenterDelegate?.failureResultWithError(errorDict: resultDict)
    //            }
            }, failure: { (error)  in
                
               // self.loginPresenterDelegate?.failureResultWithNetworkError(error: error)
                self.showLoginError("The login failed. please check your credentials.");
            })

            
            
          

        }


    public func showLoginError(_ error: String) {
        let alert = UIAlertController(title: "Login Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

}



//Switches views, depending if user is logged in or not.
class Switcher {

    static func updateRootVC(){

        let status = UserDefaults.standard.bool(forKey: "loggedIn")
        var rootVC : UIViewController?

        print(status)


        if(status == true){
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainvc") as! UINavigationController
        }else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginController
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        guard let window = appDelegate.window, let rootViewController = window.rootViewController else {
            return
        }

        guard let vc = rootVC else { return }
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()

        UIView.transition(with: window, duration: 0.3, options: [.transitionFlipFromRight, .preferredFramesPerSecond60 ], animations: {
            window.rootViewController = vc
        }, completion: { completed in
            // maybe do something here
        })

    }

}

extension LoginController {
  
    func hideKeyboard() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

