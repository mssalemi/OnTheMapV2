//
//  StudentsTableViewController.swift
//  OnTheMapV2
//
//  Created by Mehdi Salemi on 2/29/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

class StudentsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Students"
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.sharedClient().students.count
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StudentCell")!
        
        let student = Students.sharedClient().students[indexPath.row]
        cell.textLabel?.text = student.firstName + "-" + student.lastName
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if verifyUrl(Students.sharedClient().students[indexPath.row].mediaURL) {
            if let toOpen = Students.sharedClient().students[indexPath.row].mediaURL {
                let app = UIApplication.sharedApplication()
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    private func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = Students.sharedClient().students[fromIndexPath.row]
        Students.sharedClient().students.removeAtIndex(fromIndexPath.row)
        Students.sharedClient().students.insert(itemToMove, atIndex: toIndexPath.row)
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    
    
}
