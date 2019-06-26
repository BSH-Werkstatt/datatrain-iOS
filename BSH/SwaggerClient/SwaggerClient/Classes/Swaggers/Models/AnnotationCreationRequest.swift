//
// AnnotationCreationRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct AnnotationCreationRequest: Codable {
    
    public var items: [AnnotationCreationRequestItem]
    public var userToken: String
    
    public init(items: [AnnotationCreationRequestItem], userToken: String) {
        self.items = items
        self.userToken = userToken
    }
    
    
}


