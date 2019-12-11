//
//  NetworkManager.swift
//  BSH
//
//  Created by BSH iMac on 02/12/19.
//  Copyright © 2019 Tum LS1. All rights reserved.
//

import Foundation
import Alamofire

enum API_Names{
    case LoginApi
}

enum RequestType : String{
    case GET
    case POST
    
}
struct UserCredentials { // Model
    let name: String
    let password: String
}

struct Server_APIs {
   

    static let BASE_URL = "https://issuetracking.bsh-sdd.com/rest/api/2"
    static let API_LOGIN = String(format: "%@/myself", BASE_URL)
}
class NetworkManager{
     static let shared = NetworkManager()
     var userCredentials : UserCredentials!
    //Initializer access level change now
    private init(){}
    var isAuthenticationSuccess = false;
    func authenticateUserWithServer(username:String,password:String) ->Bool{
        //TO DO
        let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        let customerURL = "https://issuetracking.bsh-sdd.com/rest/api/latest/myself"
        Alamofire.request(customerURL,
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers:headers)
            .validate()
            .responseJSON { response in
//                guard response.result.isSuccess else {
//                    print("shamil you are great");
//                    print(isAuthenticationSuccess);
//                    print(response)
//                   //sendAlert(message: LoginConstants.LOGIN_FAILURE,title:LoginConstants.ALERT_TITLE)
//                    return
//                }
//                if response.result.value != nil{
//                    //sendAlert(message: LoginConstants.LOGIN_SUCCESS,title:LoginConstants.LOGIN_TITLE)
//                    print(response)
//                }else{
//
//                }
                if(response.result.isSuccess) {
                    self.isAuthenticationSuccess = true;
                }
//                print(response);
//                print(response.result.isSuccess);
//                print(isAuthenticationSuccess);
        }
//        isAuthenticationSuccess = true
        print(self.isAuthenticationSuccess);
        print("inside network manager")
        return self.isAuthenticationSuccess
    }
    
    
      func authenticateUser(requestName : API_Names, requestType : RequestType, urlParameters : String?,  bodyParameters : Any?,completion: @escaping (_ result : Bool) -> (), failure: @escaping (_ error : Error) -> ()) {
          
          var requestURL = ""
          switch requestName {
          case .LoginApi:
              requestURL = Server_APIs.API_LOGIN
          default:
            requestURL = ""
               }
          
          if(urlParameters != nil) { requestURL.append(urlParameters!) }
          
          guard let serviceUrl = URL(string: requestURL) else { return }
          var base64Credentials = ""
          if userCredentials != nil {
          let credentialData = "\(self.userCredentials.name):\(self.userCredentials.password)".data(using: String.Encoding.utf8)!
           base64Credentials = credentialData.base64EncodedString(options: [])
          }
          
 
               let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        
         Alamofire.request(requestURL,
                                  method: .get,
                                  parameters: nil,
                                  encoding: URLEncoding.default,
                                  headers:headers)
                    .validate()
                    .responseJSON { response in
 
                        if(response.result.isSuccess) {
                            self.isAuthenticationSuccess = true;
                            completion(response.result.isSuccess)
                        }
                        else{
                           // self.isAuthenticationSuccess = fals;
                            completion(false)
                        }
                }
    
       
          

     
        
      }
}
