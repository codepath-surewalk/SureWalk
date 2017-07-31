//
//  MapViewController.swift
//  Photo Map
//
//  Created by SureWalk Team on 5/11/2017.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class MapViewController: UIViewController, MKMapViewDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate
{
    /*
     This class allows users to operate in two modes: pan mode and location selection mode.
     
     The first mode, only available when picking a pick-up location ('location'), allows the
     user to change his/her location choice by panning the map. The location is changed to the
     current center of the map.
     
     In the second mode, available both when setting a pick-up location ('location') and a
     drop-off destination ('destination') allows users to choose a specific place through the
     FourSquare API
     */
    
    //2017 SUREWalk Boundary constants
    let NORTHERNMOST_LAT = 30.318749
    let SOUTHERNMOST_LAT = 30.274864
    let EASTERNMOST_LONG = -97.710380
    let WESTERNMOST_LONG = -97.752758
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placesView: UIView!              // Contains location, destination coordinates; confirm button
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var locationPin: UIImageView!        // Red pin for (valid) pick-up location
    @IBOutlet weak var invalidPin: UIImageView!         // Gray pin for invalid (out of bounds) location
    
    @IBOutlet weak var currentLocationButton: UIBarButtonItem! // Button recenters map at current location
    
    @IBOutlet weak var alertView: AlertView!
    
    var locationCoord = CLLocationCoordinate2D()        // Coordinate of user's pick-up location
    var destinationCoord = CLLocationCoordinate2D()     // Coordinate of user's drop-off location
    var userCoord = CLLocationCoordinate2D()            // User's current coordinate
    
    var locLocked = false                               // Once the locLocked boolean is set, the user can no
    // longer change his/her location by panning the map
    
    var destChosen = false                              // Once the destChosen boolean is set, the user can only
    // change his/her location/destination using mode two
    // (interacting with FourSquare)
    
    var lastGeocodedLocation = CLLocationCoordinate2D() //used to ensure that geocoder is not inundated with requests
    
    enum MapType: NSInteger {
        case StandardMap = 0
        case SatelliteMap = 1
        case HybridMap = 2
    }
    
    var locationManager = CLLocationManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background image and gradient
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "gradient_SUREWalk.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient_SUREWalk.jpg")!)
        
        // Remove title from back button (otherwise would read: "[First Name] [Last Name]")
        navigationController?.navigationBar.backItem?.backBarButtonItem?.title = ""
        
        // Set mapView configuration
        mapView.delegate = self
        
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        
        // Set locationManager configuration
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        locationTextField.delegate = self
        setTextField(textField: locationTextField, coord: userCoord, geocode: false)
        
        destinationTextField.delegate = self
        
        showLocationPin()
        
        // User cannot confirm route until he/she chooses a valid location
        // and a valid destination
        confirmButton.isEnabled = false
        confirmButton.setTitleColor(.lightGray, for: .disabled)
        
        // Round corners of location/destination display view
        placesView.layer.cornerRadius = 6
        
        //add pan gesture recognizer on top of map to allow for more frequent location updates
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        mapView.addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = self
        
        if !AlertView.isInternetAvailable() {
            alertView.isHidden = false
        }
    }
    
    // Callback for user authorizing the app to use location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // If user authorizes, set userCoord to current location.
        // Otherwise, default user's location to UT Tower
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            manager.startUpdatingLocation()
            userCoord = (manager.location?.coordinate)!
        }
        else if status == CLAuthorizationStatus.denied {
            userCoord = CLLocationCoordinate2D(latitude: 30.286109, longitude: -97.739426)
        }
        // Set the map's view
        mapView.region = MKCoordinateRegionMakeWithDistance(userCoord, 10, 10)
        
        // Initialize lastGeocodedLocation
        lastGeocodedLocation = userCoord
        
        locationCoord = userCoord
        
        // If user is in boundaries, will show location pin.
        // Otherwise, will show invalid pin.
        showLocationPin()
    }
    
    // Call back for user movement
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCoord = (manager.location?.coordinate)!
    }
    
    // Callback for pan gesture recognizer
    func didPan(sender: UIPanGestureRecognizer) {
        
        // To save on geocode requests, only requests geocoding after pan has ended
        if sender.state == .ended {
            movedMap(geocode: true)
        }
        
        movedMap(geocode: false)
    }
    
    // Called when map is moved in any way (pan or current location button pressed)
    func movedMap(geocode: Bool) {
        
        // If mode one (panning) is still available for use
        if !locLocked && !destChosen {
            
            // Make sure the destination image pin is not visible, and the location pin is
            print("here")
            showLocationPin()
            
            // Reset the location coord to the center coordinate
            locationCoord = mapView.centerCoordinate
            
            // Set the text in the location text field based on the new location
            setTextField(textField: locationTextField, coord: locationCoord, geocode: geocode)
            
            // Make sure any 'Location' annotations (perhaps set through a FourSquare location choice) are
            // removed because we are changing the user's location choice
            removeAnnotations(named: "Location")
        }
    }
    
    // LocationsViewControllerDelegate method for responding to FourSquare location choice
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber, name: String, locDest: String) {
        
        // If user chooses his/her location on FourSquare, ensure location is unlocked
        // so that user can change his/her location by panning the map
        if locDest == "loc" {
            locLocked = false
            
            locationCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            
            setTextField(textField: locationTextField, coord: locationCoord, name: name)
            
            mapView.region = MKCoordinateRegionMakeWithDistance(locationCoord, 150, 150)
            
            // If user has previously chosen a location, replace that annotation with a new one
            replaceAnnotation(named: "Location")
            
        } else {
            // Lock location so that user cannot change it by panning
            // Lock currentLocationButton because clicking it would result
            // in undefined behavior
            locLocked = true
            destChosen = true
            currentLocationButton.isEnabled = false
            
            destinationCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            
            setTextField(textField: destinationTextField, coord: destinationCoord, name: name)
            
            mapView.region = MKCoordinateRegionMakeWithDistance(destinationCoord, 150, 150)
            
            replaceAnnotation(named: "Destination")
        }
        
        // If a destination has been chosen, alter the map configration based on the
        // validity of both the location and destination choices.
        if destChosen {
            setFullRegion()
        }
        
        // Pins are replaced by annotations
        hideAllPins()
        
        // Dismiss location picker view
        dismiss(animated: true, completion: nil)
    }
    
    // When a user clicks the text field, he/she is redirected to the FourSquare location
    // selector interface
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == locationTextField {
            locationCoord = CLLocationCoordinate2D()
            if destChosen {
                replaceAnnotation(named: "Destination")
            }
            performSegue(withIdentifier: "searchSegueLocation", sender: self)
        } else {
            
            replaceAnnotation(named: "Location")
            
            destinationCoord = CLLocationCoordinate2D()
            if locationCoord.latitude == 0 && locationCoord.longitude == 0 {
                locationCoord = mapView.centerCoordinate
            }
            performSegue(withIdentifier: "searchSegueDestination", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Check so that we don't accidentally mess with the pulsating current location blue dot annotation
        if annotation.title! != "Location" && annotation.title! != "Destination" {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView {
            // Configure annotation view
            annotationView.canShowCallout = true
            
            if (!semiInBoundaries(coord: annotation.coordinate)) {
                annotationView.image = #imageLiteral(resourceName: "map-pin-gray")
            } else {
                if (annotation.title! == "Location") {
                    annotationView.image = #imageLiteral(resourceName: "map-pin-red")
                } else {
                    annotationView.image = #imageLiteral(resourceName: "map-pin-green")
                }
            }
        }
        
        return annotationView
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        if !AlertView.isInternetAvailable() {
            alertView.isHidden = false
            return
        }
        
        API.requestRide(location:  locationCoord,
                        destination: destinationCoord,
                        date: Date(),
                        success: { (object: PFObject) in
                            let alertController = UIAlertController(title: "Ride requested!", message: "Look for a text message from your drivers.", preferredStyle: .alert)
                            
                            // create an OK action
                            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                // handle response here.
                            }
                            // add the OK action to the alert controller
                            alertController.addAction(OKAction)
                            
                            self.present(alertController, animated: true) {
                                // optional code for what happens after the alert controller has finished presenting
                            }
        }, failure: { (error: Error) in
            print("fail")
        })
    }
    
    @IBAction func goToCurrentLocation(_ sender: Any) {
        mapView.centerCoordinate = userCoord
        movedMap(geocode: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSegueLocation" || segue.identifier == "searchSegueDestination" {
            let locationsVC = segue.destination as! LocationsViewController
            locationsVC.delegate = self
            
            if segue.identifier == "searchSegueLocation" {
                locationsVC.locDest = "loc"
            } else {
                locationsVC.locDest = "dest"
            }
        }
    }
    
    func removeAnnotations(named: String) {
        let filteredAnnotations = mapView.annotations.filter { annotation in
            if annotation is MKUserLocation { return false }
            
            if let title = annotation.title, title == named {
                return true
            }
            return false
        }
        mapView.removeAnnotations(filteredAnnotations)
    }
    
    func setTextField(textField: UITextField, coord: CLLocationCoordinate2D, geocode: Bool) {
        let defaultName = "(\(coord.latitude), \(coord.longitude))"
        if geocode {
            if !semiEqualCoords(c1: coord, c2: lastGeocodedLocation, diff: 0.00005) {
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coord.latitude, longitude: coord.longitude ), completionHandler: {(placemarks, error) -> Void in
                    
                    if error != nil {
                        print("Reverse geocoder failed with error: " + error!.localizedDescription)
                        self.setTextField(textField: textField, coord: coord, name: defaultName)
                    }
                    
                    if placemarks != nil && placemarks!.count > 0 {
                        let pm = placemarks![0]
                        if pm.name == nil {
                            self.setTextField(textField: textField, coord: coord, name: defaultName)
                        } else {
                            self.setTextField(textField: textField, coord: coord, name: pm.name!)
                        }
                    }
                    else {
                        print("Problem with the data received from geocoder")
                        self.setTextField(textField: textField, coord: coord, name: defaultName)
                    }
                })
            }
            
        } else {
            setTextField(textField: textField, coord: coord, name: "(\(coord.latitude), \(coord.longitude))")
        }
    }
    
    func setTextField(textField: UITextField, coord: CLLocationCoordinate2D, name: String) {
        if semiEqualCoords(c1: coord, c2: userCoord, diff: 0.000015) {
            atCurrentLocation(textField: textField)
        } else {
            standardLocation(textField: textField, name: name)
        }
    }
    
    func semiEqualCoords(c1: CLLocationCoordinate2D , c2: CLLocationCoordinate2D, diff: Double) -> Bool {
        return abs(c1.longitude - c2.longitude) <= diff && abs(c1.latitude - c2.latitude) <= diff
    }
    
    func semiInBoundaries(coord: CLLocationCoordinate2D) -> Bool {
        return (coord.latitude >= SOUTHERNMOST_LAT && coord.latitude <= NORTHERNMOST_LAT) //because north of equator latitudes are positive
            && (coord.longitude >= WESTERNMOST_LONG && coord.longitude <= EASTERNMOST_LONG) //because east of meridian, longitudes are negative
    }
    
    func atCurrentLocation(textField: UITextField) {
        textField.text = "Current Location"
        textField.textColor = UIColor(colorLiteralRed: 14/255.0, green: 122/255.0, blue: 254/255.0, alpha: 1) //Apple system blue
    }
    
    
    func standardLocation(textField: UITextField, name: String) {
        textField.text = name
        textField.textColor = UIColor(colorLiteralRed: 191/255.0, green: 87/255.0, blue: 0/255.0, alpha: 1) //Burnt Orange
    }
    
    func hideAllPins() {
        locationPin.isHidden = true
        invalidPin.isHidden = true
    }
    
    func showLocationPin() {
        showLocationPin(blockInvalid: false)
    }
    
    func showLocationPin(blockInvalid: Bool) {
        
        // logic checks if user is setting location and if the location being chosen is in boundaries
        if (!locLocked && !destChosen && !semiInBoundaries(coord: locationCoord)) {
            locationPin.isHidden = true
            invalidPin.isHidden = false
            return
        }
        
        // otherwise, set client choices and disable invalid pin
        locationPin.isHidden = false
        
        invalidPin.isHidden = true
    }
    
    func setFullRegion() {
        
        // If we've previously added a route, remove it
        for overlay in mapView.overlays {
            mapView.remove(overlay)
        }
        
        // Replace both location and destination annotations
        replaceAnnotation(named: "Location")
        replaceAnnotation(named: "Destination")
        
        // Set map region so that the user can see both the location and destination
        let midpoint = CLLocationCoordinate2DMake((locationCoord.latitude + destinationCoord.latitude) / 2, (locationCoord.longitude + destinationCoord.longitude) / 2)
        let latDistance = abs(locationCoord.latitude - destinationCoord.latitude) * 250000
        let longDistance = abs(locationCoord.longitude - destinationCoord.longitude) * 250000
        let region = MKCoordinateRegionMakeWithDistance(midpoint, latDistance, longDistance)
        mapView.setRegion(region, animated: true)
        
        // If both location and destination are in boundaries, add route between them
        // and enable the confirmation button.
        // Otherwise, ensure that the confirmation button is disabled.
        if (semiInBoundaries(coord: locationCoord) && semiInBoundaries(coord: destinationCoord)) {
            addDirections()
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
    
    func addDirections() {
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: locationCoord))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoord))
        directionsRequest.transportType = .walking
        let directions = MKDirections(request: directionsRequest)
        let sureMapView = mapView
        directions.calculate { (response: MKDirectionsResponse?, error: Error?) in
            if !(error != nil) {
                for route in response!.routes {
                    sureMapView?.add(route.polyline, level: .aboveRoads)
                }
            }
        }
    }
    
    func replaceAnnotation(named: String) {
        var coord = CLLocationCoordinate2D()
        
        if named == "Location" {
            coord = locationCoord
        } else {
            coord = destinationCoord
        }
        
        removeAnnotations(named: named)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = named
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // Allows us to use a pan gesture recognizer on top of the standard map gesture recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func switchMapStyle(_ sender: UISegmentedControl) {
        print(sender)
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .hybrid
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
