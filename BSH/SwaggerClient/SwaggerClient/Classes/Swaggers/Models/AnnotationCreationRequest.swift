//
// AnnotationCreationRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct AnnotationCreationRequest: Codable {
    
    public var points: [Point]
    public var type: String
    public var label: String
    public var userId: Int
    
    public init(points: [Point], type: String, label: String, userId: Int) {
        self.points = points
        self.type = type
        self.label = label
        self.userId = userId
    }
    
    
}
