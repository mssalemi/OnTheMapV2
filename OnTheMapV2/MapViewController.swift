//
//  MapViewController.swift
//  OnTheMapV2
//
//  Created by Mehdi Salemi on 2/29/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController,  MKMapViewDelegate, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    var dropPin : UIBarButtonItem!
    var logoutButton : UIBarButtonItem!
    
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    // Mark : View Functions
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("Udacity Session ID : \(UdacityClient.sharedClient().currentSessionID)")
        
        mapView.delegate = self
        self.addStudentsToMap()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        dropPin = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewPin:")
        logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutViewButtonPressed:")
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.rightBarButtonItem = dropPin
        navigationItem.leftBarButtonItem = logoutButton
        
        if UdacityClient.sharedClient().loggedIn == false {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        super.viewWillAppear(animated)
    }
    
    // Mark : Bar Button Functions
    @IBAction func logoutViewButtonPressed(sender:AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LogoutViewController")
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func addNewPin(sender:AnyObject) {
        dropView.hidden = false
    }
    
    // Mark : MKMapKit Functions
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        if (annotation.title! == nameTextField.text!) {
            pinView?.pinTintColor = UIColor.blueColor()
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    }
    
    // Get Method
    func addStudentsToMap(){
        
        print("Adding Students to Map")

        func handler(data:NSData?,response:NSURLResponse?, error:NSError?) {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard (error == nil) else{
                    self.alert("Network Error")
                    return
                }
                
                guard let data = data else{
                    self.alert("Error: No Data Found")
                    return
                }
                
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    self.alert("Error: Parsing JSON data")
                    return
                }
                
                guard let allLocations = parsedResult["results"] as? [[String:AnyObject]] else {
                    self.alert("Error Creating all Locations")
                    return
                }
                
                Students.sharedClient().addStudents(allLocations)
                
                var locations = [MKPointAnnotation]()
                for loc in allLocations {
                    let newPoint = MKPointAnnotation()
                    newPoint.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(loc["latitude"] as! Double), longitude: CLLocationDegrees(loc["longitude"] as! Double))
                    newPoint.title = "\(loc["firstName"] as! String) \(loc["lastName"] as! String)"
                    newPoint.subtitle = loc["mediaURL"] as? String
                    locations.append(newPoint)
                }
                self.mapView.addAnnotations(locations)
            }
        }
        ParseClient.sharedClient().getMethod(handler)
    }
    
    // Mark : Post Method
    func addPostPin() {
        self.goToLocation()
        
        func handler(data:NSData?,response:NSURLResponse?, error:NSError?) {
            dispatch_async(dispatch_get_main_queue()) {
                guard (error == nil) else{
                    self.alert("Network Error")
                    return
                }
                guard let data = data else{
                    self.alert("No Data Found Error")
                    return
                }
                print(NSString(data: data, encoding: NSUTF8StringEncoding))
                self.goToLocation()
            }
        }
        print(cL)
        ParseClient.sharedClient().postMethod("\(locationTextField.text)", mediaURL: "\(linkTextField.text)", lat: cL[0], long: cL[1], handler: handler)
    }
    
    // Mark: Location Manager Functions
    var cL = [0.0,0.0]
    var CLCurrentLocation : CLLocation!
    var currentLocationString = ""
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        cL[0] = locValue.latitude
        cL[1] = locValue.longitude
        
        self.CLCurrentLocation = locations[locations.count - 1]
        
        CLGeocoder().reverseGeocodeLocation(CLCurrentLocation) { (myPlacements, myError) -> Void in
            if myError != nil{
                print("Cannot Find Location")
            }
            if let myPlacement = myPlacements?.first {
                let myAddress = " \(myPlacement.locality!) \(myPlacement.country!) \(myPlacement.postalCode!)"
                self.currentLocationString = myAddress
            }
        }
    }
    
    // Mark : View Functions
    @IBAction func drop(sender: UIButton) {
        self.addPostPin()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addStudentsToMap()
        }
    }
    
    func goToLocation(){
        CLGeocoder().geocodeAddressString(locationTextField.text!, completionHandler:  { (placemark, error) in
            if (error == nil) {placemark?.first?.location?.coordinate.latitude
                self.cL[0] = (placemark?.first?.location?.coordinate.latitude)!
                self.cL[1] = (placemark?.first?.location?.coordinate.longitude)!
                self.mapView.centerCoordinate.latitude = self.cL[0]
                self.mapView.centerCoordinate.longitude = self.cL[1]
                self.mapView.setZoomByDelta(0.1, animated: true)
                self.locationManager.stopUpdatingLocation()
            } else {
                self.alert("Could not Find Location")
            }
        })
    }

    @IBAction func cancel(sender: UIButton) {
        locationTextField.text! = ""
        nameTextField.text! = ""
        linkTextField.text! = ""
        dropView.hidden = true
    }
    
    // Mark : Alert Method
    func alert (reason : String){
        let controller = UIAlertController()
        controller.title = "Login Error!"
        controller.message = reason
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.addAction(okAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }

}

extension MKMapView {
    
    // delta is the zoom factor
    // 2 will zoom out x2
    // .5 will zoom in by x2
    
    func setZoomByDelta(delta: Double, animated: Bool) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;
        
        setRegion(_region, animated: animated)
    }
}


