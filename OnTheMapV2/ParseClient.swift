//
//  ParseClient.swift
//  OnTheMapV2
//
//  Created by Mehdi Salemi on 2/29/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation


class ParseClient : NSObject{
    
    private static var sharedInstance = ParseClient()
    
    class func sharedClient() -> ParseClient {
        return sharedInstance
    }
    
    override init() {
        super.init()
    }
    
    
    func getMethod(handler : (data:NSData?,response:NSURLResponse?, error:NSError?) -> Void ) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.Parse.baseURL)!)
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume() 
    }
    
    func postMethod(mapString : String, mediaURL : String, lat : Double, long : Double, handler : (data:NSData?,response:NSURLResponse?, error:NSError?) -> Void ) {
        
        
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityClient.sharedClient().currentSessionID)\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 48.8567, \"longitude\": 2.3508}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume()
        
    }
    
}