//
//  ViewController.swift
//  SwiftMaps
//
//  Created by Sezer on 29.08.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescripton: UITextField!
    
    var chosenLatitude=Double()
    var chosenLongitude=Double()
    
    var locationManager=CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate=self
        mapView.delegate = self
        
        getAllMarks()
        
        locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer=UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration=2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
     
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchedPoint=gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates=self.mapView.convert(touchedPoint,toCoordinateFrom: self.mapView)
            
            chosenLatitude=touchedCoordinates.latitude
            chosenLongitude=touchedCoordinates.longitude
            
            let annotation=MKPointAnnotation()
            annotation.coordinate=touchedCoordinates
            annotation.title=txtName.text
            annotation.subtitle=txtDescripton.text
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span=MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region=MKCoordinateRegion(center:location,span:span)
        mapView.setRegion(region, animated: true)
        
        // NOTE: locations[0] brings user's last location
    }
    @IBAction func btnSaveClicked(_ sender: Any) {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if (txtName.text ?? "").isEmpty || (txtDescripton.text ?? "").isEmpty || chosenLatitude==0 || chosenLongitude==0{
            let alert = UIAlertController(title: "Warning", message: "Fill all blanks!", preferredStyle: UIAlertController.Style.alert)
            
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            return
        }
        
        let newPlace=NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(txtName.text, forKey: "title")
        newPlace.setValue(txtDescripton.text, forKey: "comment")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID() , forKey:"id")
        
        do{
            try context.save()
            print("Success")
        }catch{
            print("Failed")
        }
    }
    
    func getAllMarks(){
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults=false
        
        do{
            let results = try  context.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    
                    var Places = PlacesModel()
                    
                    if let title = result.value(forKey: "title") as? String{
                        Places.name=title
                    }
                    if let comment = result.value(forKey: "comment") as? String{
                        Places.comment=comment
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double{
                        Places.longitude=longitude
                    }
                    if let latidute = result.value(forKey: "latitude") as? Double{
                        Places.latidute=latidute
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        Places.id=id
                    }
                    
                    let lc = CLLocation.init(latitude: Places.latidute ?? 0, longitude: Places.longitude ?? 0)
                    
                    let annotation=MKPointAnnotation()
                    annotation.coordinate=lc.coordinate
                    annotation.title=Places.name
                    annotation.subtitle=Places.comment
                    self.mapView.addAnnotation(annotation)
                }
               }
               catch{
                   print("Error when fetching")
               }
        
    }
    

}

