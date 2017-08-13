//
//  ViewController.swift
//  BikeFinder
//
//  Created by Emre Dogan on 11/08/2017.
//  Copyright © 2017 Emre Dogan. All rights reserved.
//

import UIKit
import GeoFire
import MapKit
import FirebaseDatabase
import SCLAlertView

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    let geoCoder = CLGeocoder()
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        
        let pinImage = UIImage(named: "1.png")
        let imageView = UIImageView()
        
        
        
        
        
        imageView.image = resizeImage(image: pinImage!, newWidth: 50)
        
    //    imageView.frame = CGRect(x: 100, y: 100, width: 10, height: 10)
        
        
        
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = UIViewContentMode.center
        
        imageView.center.y = UIScreen.main.bounds.size.height*0.5
        imageView.center.x = UIScreen.main.bounds.size.width*0.5
        
        
        self.view.addSubview(imageView)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        
        let userLocationView = self.mapView(mapView, viewFor: userLocation)
        userLocationView?.superview?.bringSubview(toFront: userLocationView!)
        
        
        
        if let loc = userLocation.location {
            
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
            
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        let annoIdentifier = "Bike"
        
        
        
        
        if annotation.isKind(of: MKUserLocation.self) {
            
            
            
            
            
            // USE THIS CODE IF YOU WANT TO PUT A SPECIFIC IMAGE FOR USER'S CURRENT LOCATION ON THE MAP
            
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
//            
//            let pinImage = UIImage(named: "user")
//            let size = CGSize(width: 20, height: 20)
//            UIGraphicsBeginImageContext(size)
//            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//            
//            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//            
//            UIGraphicsEndImageContext()
//            
//            annotationView?.image = resizedImage
            
        
        
            
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
            
        }
        
        
        if let annotationView = annotationView, let anno = annotation as? BikeAnnotation {
            
            formatAnnotation(pinView: annotationView, forMapView: mapView)
            annotationView.canShowCallout = false
       //     annotationView.image = UIImage(named: "\(anno.bikeNumber)")
            
            annotationView.image = UIImage(named: "1.png")
            
        
        
        
    }
        
        return annotationView
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        
        
        
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false
        )
        
        
        
        let alertView = SCLAlertView(appearance: appearance)
        
        
        
        
        
        if let anno =  view.annotation as? BikeAnnotation {
            
            
            
            let place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "Bike Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let location = CLLocation(latitude: anno.coordinate.latitude, longitude: anno.coordinate.longitude)
            
            
            
            geoCoder.reverseGeocodeLocation(location)
            {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                // Address dictionary
                print(placeMark.addressDictionary)
                
                // Location name
                if let locationName = placeMark.addressDictionary?["Name"] as? NSString
                {
                    print(locationName)
                }
                
                // Street address
                if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
                {
                    print(street)
                    
                    if let city = placeMark.addressDictionary?["City"] as? NSString
                    {
                        alertView.showSuccess("Find your bike", subTitle: "\(street) / \(city)")
                        
                    } else {
                        alertView.showSuccess("Find your bike", subTitle: "\(street)")
                    }
                    
                    
                } else {
                    alertView.showSuccess("Find your bike", subTitle: "Choose your travel type")
                }
                
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString
                {
                    print(city)
                    
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary?["ZIP"] as? NSString
                {
                    print(zip)
                }
                
                // Country
                if let country = placeMark.addressDictionary?["Country"] as? NSString
                {
                    print(country)
                }
                
                
                
                
            }
            
            
            
            alertView.addButton("Walking") {
                let options = [MKLaunchOptionsMapCenterKey: NSValue (mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking] as [String : Any]
                
                MKMapItem.openMaps(with: [destination], launchOptions: options)
                print("Second button tapped")
            }
            
            alertView.addButton("Driving") {
                let options = [MKLaunchOptionsMapCenterKey: NSValue (mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
                
                MKMapItem.openMaps(with: [destination], launchOptions: options)
                print("Second button tapped")
            }
            
            alertView.addButton("Public Transport") {
                let options = [MKLaunchOptionsMapCenterKey: NSValue (mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit] as [String : Any]
                
                MKMapItem.openMaps(with: [destination], launchOptions: options)
                print("Second button tapped")
            }
            
//            alertView.addButton("Remove Bike") {
//                let allAnnotations = self.mapView.annotations
//                
//                for _annotation in allAnnotations {
//                    if let annotation = _annotation as? MKAnnotation
//                    {
//                        self.mapView.removeAnnotation(annotation)
//                        self.geoFire.removeKey("1")
//                    }
//                }
//                
//                
//            }
            
            
        }
    

        
        
    
        
    }
    
    func formatAnnotation(pinView: MKAnnotationView, forMapView: MKMapView) {
        
        
        
        
        
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = log2(zoomWidth) - 9
        print("...REGION DID CHANGE: ZOOM FACTOR \(zoomFactor)")
        
        var scale = 0.05 * zoomFactor //Modify to whatever scale you need.
        
        if scale < 0.18 {
            scale = 0.18
        } else if scale > 0.23 {
            scale = 0.23
        }
        
        print("EMREDOGAN \(scale)")
        
        pinView.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        
    }
    
    
    
    
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated: Bool) {
            let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            
            showBikesOnMap(location: loc)
            
        
            
            
            //ACTIVATE THIS PART IF YOU WANT TO MAKE ICONS DISAPPEAR FOR CERTAIN DISTANCES
            
//            let annotations = self.mapView.annotations
//            
//            
//            
//            for annotation in annotations
//            {
//                
//                self.mapView.view(for: annotation)?.isHidden = false
//                
//                if annotation.isKind(of: MKUserLocation.self) {
//                    
//                    self.mapView.view(for: annotation)?.isHidden = false
//                    
//                }
//                
//                else if (self.mapView.region.span.latitudeDelta > 0.060)
//                {
//                    
//                    self.mapView.view(for: annotation)?.isHidden = true
//                    
//                }
//                
//                else if (self.mapView.region.span.latitudeDelta < 0.060) {
//                    
//                    self.mapView.view(for: annotation)?.isHidden = false
//                    
//                } else {
//                    self.mapView.view(for: annotation)?.isHidden = false
//                    
//                }
//                
//            }
        }
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let annotations = self.mapView.annotations
//        
//        for annotation in annotations
//        {
//            if (self.mapView.region.span.latitudeDelta > 0.010)
//            {
//                
//                self.mapView.view(for: annotation)?.isHidden = true
//                
//            }
//            else {
//                
//                self.mapView.view(for: annotation)?.isHidden = false
//                
//            }
//        }
//    }
    
    
    
        
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            
            if let anno =  view.annotation as? BikeAnnotation {
                let place = MKPlacemark(coordinate: anno.coordinate)
                let destination = MKMapItem(placemark: place)
                destination.name = "Bike Sighting"
                let regionDistance: CLLocationDistance = 1000
                let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
                
                let options = [MKLaunchOptionsMapCenterKey: NSValue (mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking] as [String : Any]
                
                MKMapItem.openMaps(with: [destination], launchOptions: options)
                
                
            }
            
        }
    
    
    
    @IBAction func removeAllBikes(_ sender: Any) {
        
        
        let allAnnotations = self.mapView.annotations
        
                        for _annotation in allAnnotations {
                            if let annotation = _annotation as? MKAnnotation
                            {
                                self.mapView.removeAnnotation(annotation)
                                self.geoFire.removeKey("1")
                            }
                        }
    }
    
    
    @IBAction func showUser(_ sender: Any) {
        
        
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
        
    }
    
    
    
    
    @IBAction func spotBikes(_ sender: Any) {
        
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        let rand = arc4random_uniform(2) + 1
        print("EMRE: \(rand)")
        createSighting(forLocation: location, withBike: Int(rand))
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    
    func createSighting(forLocation location: CLLocation, withBike bikeID: Int) {
    
        geoFire.setLocation(location, forKey: "\(bikeID)")
        
        print("EMRE: Sight created")
    }
    
    func showBikesOnMap(location: CLLocation) {
        print("000")
        let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            print("1111")
            
            
            if let key = key, let location = location {
                let anno = BikeAnnotation(coordinate: location.coordinate, bikeNumber: Int(key)!)
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(anno)
                }
                
                
                
                print("2222")
            }
        })
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    


}



