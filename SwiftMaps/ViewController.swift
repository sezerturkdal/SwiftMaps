//
//  ViewController.swift
//  SwiftMaps
//
//  Created by Sezer on 29.08.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager=CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate=self
        mapView.delegate = self
        
        locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span=MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region=MKCoordinateRegion(center:location,span:span)
        mapView.setRegion(region, animated: true)
        
        // NOTE: locations[0] brings user's last location
    }


}

