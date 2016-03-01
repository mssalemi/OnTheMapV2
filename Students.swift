//
//  Students.swift
//  OnTheMapV2
//
//  Created by Mehdi Salemi on 2/29/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation

class Students: NSObject {
    
    private static var sharedInstance = Students()
    
    class func sharedClient() -> Students {
        return sharedInstance
    }
    
    var students : [StudentInformation]!
    
    override init() {
        super.init()
    }
    
    func addStudents(allStudents : [[String:AnyObject]]) {
        students = [StudentInformation]()
        for student in allStudents {
            students.append(StudentInformation(student: student))
        }
        let sortedArray = students.sort { $0.updatedAt.compare($1.updatedAt) == .OrderedDescending }
        students = sortedArray
    }
    
    
    
}