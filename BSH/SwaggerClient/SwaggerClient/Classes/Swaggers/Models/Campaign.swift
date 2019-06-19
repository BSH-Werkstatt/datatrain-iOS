//
// Campaign.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Campaign: Codable {

    public var _id: String
    public var ownerId: String
    public var type: CampaignType
    public var name: String
    public var _description: String
    public var taxonomy: [String]
    public var image: String?

    public init(_id: String, ownerId: String, type: CampaignType, name: String, _description: String, taxonomy: [String], image: String?) {
        self._id = _id
        self.ownerId = ownerId
        self.type = type
        self.name = name
        self._description = _description
        self.taxonomy = taxonomy
        self.image = image
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case ownerId
        case type
        case name
        case _description = "description"
        case taxonomy
        case image
    }


}

