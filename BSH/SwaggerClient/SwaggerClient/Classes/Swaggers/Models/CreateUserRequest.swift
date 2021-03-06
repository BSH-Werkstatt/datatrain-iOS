//
// CreateUserRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct CreateUserRequest: Codable {

    public var email: String
    public var name: String
    public var userType: String?

    public init(email: String, name: String, userType: String?) {
        self.email = email
        self.name = name
        self.userType = userType
    }


}

