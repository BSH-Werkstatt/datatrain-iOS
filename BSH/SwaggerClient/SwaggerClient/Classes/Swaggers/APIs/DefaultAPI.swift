//
// DefaultAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire



open class DefaultAPI {
    /**
     
     - parameter request: (body)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func createUser(request: CreateUserRequest, completion: @escaping ((_ data: User?,_ error: Error?) -> Void)) {
        createUserWithRequestBuilder(request: request).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - POST /users
     - examples: [{contentType=application/json, example={
     "id" : "id",
     "email" : "email"
     }}]
     
     - parameter request: (body)
     
     - returns: RequestBuilder<User>
     */
    open class func createUserWithRequestBuilder(request: CreateUserRequest) -> RequestBuilder<User> {
        let path = "/users"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: request)
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<User>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
    /**
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getAllCampaigns(completion: @escaping ((_ data: [Campaign]?,_ error: Error?) -> Void)) {
        getAllCampaignsWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - GET /campaigns
     - examples: [{contentType=application/json, example=[ {
     "image" : "image",
     "name" : "name",
     "description" : "description",
     "id" : "id",
     "taxonomy" : [ "taxonomy", "taxonomy" ],
     "ownerId" : "ownerId",
     "type" : { }
     }, {
     "image" : "image",
     "name" : "name",
     "description" : "description",
     "id" : "id",
     "taxonomy" : [ "taxonomy", "taxonomy" ],
     "ownerId" : "ownerId",
     "type" : { }
     } ]}]
     
     - returns: RequestBuilder<[Campaign]>
     */
    open class func getAllCampaignsWithRequestBuilder() -> RequestBuilder<[Campaign]> {
        let path = "/campaigns"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<[Campaign]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    /**
     
     - parameter campaignId: (path)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getAllImages(campaignId: String, completion: @escaping ((_ data: [ImageData]?,_ error: Error?) -> Void)) {
        getAllImagesWithRequestBuilder(campaignId: campaignId).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - GET /campaigns/{campaignId}/images
     - examples: [{contentType=application/json, example=[ {
     "campaignId" : "campaignId",
     "annotations" : [ {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     }, {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     } ],
     "id" : "id",
     "userId" : "userId"
     }, {
     "campaignId" : "campaignId",
     "annotations" : [ {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     }, {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     } ],
     "id" : "id",
     "userId" : "userId"
     } ]}]
     
     - parameter campaignId: (path)
     
     - returns: RequestBuilder<[ImageData]>
     */
    open class func getAllImagesWithRequestBuilder(campaignId: String) -> RequestBuilder<[ImageData]> {
        var path = "/campaigns/{campaignId}/images"
        let campaignIdPreEscape = "\(campaignId)"
        let campaignIdPostEscape = campaignIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{campaignId}", with: campaignIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<[ImageData]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    /**
     
     - parameter campaignId: (path)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getCampaign(campaignId: String, completion: @escaping ((_ data: Campaign?,_ error: Error?) -> Void)) {
        getCampaignWithRequestBuilder(campaignId: campaignId).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - GET /campaigns/{campaignId}
     - examples: [{contentType=application/json, example={
     "image" : "image",
     "name" : "name",
     "description" : "description",
     "id" : "id",
     "taxonomy" : [ "taxonomy", "taxonomy" ],
     "ownerId" : "ownerId",
     "type" : { }
     }}]
     
     - parameter campaignId: (path)
     
     - returns: RequestBuilder<Campaign>
     */
    open class func getCampaignWithRequestBuilder(campaignId: String) -> RequestBuilder<Campaign> {
        var path = "/campaigns/{campaignId}"
        let campaignIdPreEscape = "\(campaignId)"
        let campaignIdPostEscape = campaignIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{campaignId}", with: campaignIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Campaign>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    /**
     
     - parameter campaignId: (path)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getLeaderboard(campaignId: String, completion: @escaping ((_ data: Leaderboard?,_ error: Error?) -> Void)) {
        getLeaderboardWithRequestBuilder(campaignId: campaignId).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - GET /campaigns/{campaignId}/leaderboard
     - examples: [{contentType=application/json, example={
     "scores" : [ {
     "score" : 0.8008281904610115,
     "userId" : "userId"
     }, {
     "score" : 0.8008281904610115,
     "userId" : "userId"
     } ],
     "campaignId" : "campaignId",
     "id" : "id"
     }}]
     
     - parameter campaignId: (path)
     
     - returns: RequestBuilder<Leaderboard>
     */
    open class func getLeaderboardWithRequestBuilder(campaignId: String) -> RequestBuilder<Leaderboard> {
        var path = "/campaigns/{campaignId}/leaderboard"
        let campaignIdPreEscape = "\(campaignId)"
        let campaignIdPostEscape = campaignIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{campaignId}", with: campaignIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Leaderboard>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    /**
     
     - parameter campaignId: (path)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getRandomImage(campaignId: String, completion: @escaping ((_ data: ImageData?,_ error: Error?) -> Void)) {
        getRandomImageWithRequestBuilder(campaignId: campaignId).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - GET /campaigns/{campaignId}/images/random
     - examples: [{contentType=application/json, example={
     "campaignId" : "campaignId",
     "annotations" : [ {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     }, {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     } ],
     "id" : "id",
     "userId" : "userId"
     }}]
     
     - parameter campaignId: (path)
     
     - returns: RequestBuilder<ImageData>
     */
    open class func getRandomImageWithRequestBuilder(campaignId: String) -> RequestBuilder<ImageData> {
        var path = "/campaigns/{campaignId}/images/random"
        let campaignIdPreEscape = "\(campaignId)"
        let campaignIdPostEscape = campaignIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{campaignId}", with: campaignIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<ImageData>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    /**
     
     - parameter email: (path)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getUserByEmail(email: String, completion: @escaping ((_ data: User?,_ error: Error?) -> Void)) {
        getUserByEmailWithRequestBuilder(email: email).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - GET /users/byEmail/{email}
     - examples: [{contentType=application/json, example={
     "id" : "id",
     "email" : "email"
     }}]
     
     - parameter email: (path)
     
     - returns: RequestBuilder<User>
     */
    open class func getUserByEmailWithRequestBuilder(email: String) -> RequestBuilder<User> {
        var path = "/users/byEmail/{email}"
        let emailPreEscape = "\(email)"
        let emailPostEscape = emailPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{email}", with: emailPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<User>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    /**
     
     - parameter imageFile: (form)
     - parameter userToken: (query)
     - parameter campaignId: (path)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func postImage(imageFile: URL, userToken: String, campaignId: String, completion: @escaping ((_ data: ImageData?,_ error: Error?) -> Void)) {
        postImageWithRequestBuilder(imageFile: imageFile, userToken: userToken, campaignId: campaignId).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - POST /campaigns/{campaignId}/images
     - examples: [{contentType=application/json, example={
     "campaignId" : "campaignId",
     "annotations" : [ {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     }, {
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     } ],
     "id" : "id",
     "userId" : "userId"
     }}]
     
     - parameter imageFile: (form)
     - parameter userToken: (query)
     - parameter campaignId: (path)
     
     - returns: RequestBuilder<ImageData>
     */
    open class func postImageWithRequestBuilder(imageFile: URL, userToken: String, campaignId: String) -> RequestBuilder<ImageData> {
        var path = "/campaigns/{campaignId}/images"
        let campaignIdPreEscape = "\(campaignId)"
        let campaignIdPostEscape = campaignIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{campaignId}", with: campaignIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let formParams: [String:Any?] = [
            "imageFile": imageFile
        ]
        
        let nonNullParameters = APIHelper.rejectNil(formParams)
        let parameters = APIHelper.convertBoolToString(nonNullParameters)
        
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "userToken": userToken
            ])
        
        let requestBuilder: RequestBuilder<ImageData>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    
    /**
     
     - parameter campaignId: (path)
     - parameter imageId: (path)
     - parameter request: (body)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func postImageAnnotation(campaignId: String, imageId: String, request: AnnotationCreationRequest, completion: @escaping ((_ data: Annotation?,_ error: Error?) -> Void)) {
        postImageAnnotationWithRequestBuilder(campaignId: campaignId, imageId: imageId, request: request).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }
    
    
    /**
     - POST /campaigns/{campaignId}/images/{imageId}/annotations
     - examples: [{contentType=application/json, example={
     "imageId" : "imageId",
     "campaignId" : "campaignId",
     "id" : "id",
     "label" : "label",
     "type" : "type",
     "userId" : "userId",
     "points" : [ {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     }, {
     "x" : 0.8008281904610115,
     "y" : 6.027456183070403
     } ]
     }}]
     
     - parameter campaignId: (path)
     - parameter imageId: (path)
     - parameter request: (body)
     
     - returns: RequestBuilder<Annotation>
     */
    open class func postImageAnnotationWithRequestBuilder(campaignId: String, imageId: String, request: AnnotationCreationRequest) -> RequestBuilder<Annotation> {
        var path = "/campaigns/{campaignId}/images/{imageId}/annotations"
        let campaignIdPreEscape = "\(campaignId)"
        let campaignIdPostEscape = campaignIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{campaignId}", with: campaignIdPostEscape, options: .literal, range: nil)
        let imageIdPreEscape = "\(imageId)"
        let imageIdPostEscape = imageIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{imageId}", with: imageIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: request)
        
        let url = URLComponents(string: URLString)
        
        let requestBuilder: RequestBuilder<Annotation>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
        
        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    
}
