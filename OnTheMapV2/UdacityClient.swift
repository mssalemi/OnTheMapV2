//
//  UdacityClient.swift
//  OnTheMapV2
//
//  Created by Mehdi Salemi on 2/29/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation


class UdacityClient: NSObject {
    
    var loggedIn : Bool!
    
    private static var sharedInstance = UdacityClient()
    
    class func sharedClient() -> UdacityClient {
        return sharedInstance
    }
    
    var currentSessionID : String!
    
    override init() {
        super.init()
    }
    
    
    func loginToUdacity(username : String, password : String, handler : (data:NSData?,response:NSURLResponse?, error:NSError?) -> Void ) {
        
        let url = NSURL(string: Constants.Udacity.base_url)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume()
    }
    
    
}