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

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescripton: UITextField!
    
    var chosenLatitude=Double()
    var chosenLongitude=Double()
    
    var locationManager=CLLocationManager()
    var viewMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate=self
        mapView.delegate = self
        
        setViewMode(vm: viewMode)
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
        
        /* Getting user's location
        let span=MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region=MKCoordinateRegion(center:location,span:span)
        mapView.setRegion(region, animated: true)
        */
        // NOTE: locations[0] brings user's last location
    }
    @IBAction func btnSaveClicked(_ sender: Any) {
        
        if(viewMode==true){
            setViewMode(vm: false)
            return
        }
        
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
            
            txtName.text?.removeAll()
            txtDescripton.text?.removeAll()
            setViewMode(vm: true)
            getAllMarks()
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
            var sumLongitudes=Double()
            sumLongitudes=0
            var sumLatidutes=Double()
            sumLatidutes=0
            var listOfPlaces=[PlacesModel]()
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
                        sumLongitudes=sumLongitudes+longitude
                    }
                    if let latidute = result.value(forKey: "latitude") as? Double{
                        Places.latidute=latidute
                        sumLatidutes=sumLatidutes+latidute
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
                    
                    listOfPlaces.append(Places)
                }
              // SET SCALE
                    let maxLatitude = listOfPlaces.map { $0.latidute ?? 0 }.max()
                    let maxLongitude = listOfPlaces.map { $0.longitude ?? 0 }.max()
                    let minLatitude = listOfPlaces.map { $0.latidute ?? 0 }.min()
                    let minLongitude = listOfPlaces.map { $0.longitude ?? 0 }.min()
           
                    let MAP_PADDING=0.005
                    let MINIMUM_VISIBLE_LATITUDE = 2.0
            
                    let ltt = (Double(minLatitude ?? 0) + Double(maxLatitude ?? 0)) / 2;
                    let lng = (Double(minLongitude ?? 0) + Double(maxLongitude ?? 0)) / 2;

                    var latitudeDelta = (Double(maxLatitude ?? 0) + Double(minLatitude ?? 0)) * MAP_PADDING;

                    latitudeDelta = (latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
                        ? MINIMUM_VISIBLE_LATITUDE
                        : latitudeDelta;

                    let longitudeDelta = (Double(maxLongitude ?? 0) + Double(minLongitude ?? 0)) * MAP_PADDING;
            
                    locationManager.stopUpdatingLocation()
            
                    let location = CLLocationCoordinate2D(latitude: ltt, longitude: lng)
                    let span=MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
                    let region=MKCoordinateRegion(center:location,span:span)
                    mapView.setRegion(region, animated: true)
               }
               catch{
                   print("Error when fetching")
               }
    }
    func setViewMode(vm:Bool){
        txtName.isHidden=vm
        txtDescripton.isHidden=vm
        if(vm){
            saveButton.setTitle("Add new place", for: .normal)
        }else{
            saveButton.setTitle("Save", for: .normal)
        }
        
        for constraint in self.view.constraints {
            if constraint.identifier == "mapViewDefaultTop" {
                if vm==false{
                    constraint.constant = 200
                }else{
                    constraint.constant = 0
                }
            }
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        viewMode = vm
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        setViewMode(vm: true) // Cancel save new place
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }
        let reuseId="myAnnotation"
        var pinView=mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView==nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout=true
            pinView?.tintColor=UIColor.blue
            
            let button=UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView=button
        }else{
            pinView?.annotation=annotation
        }
        return pinView
    }
    

}

