//
//  MapViewController.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController : UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin] = []
    var dataController: DataController!
    
    override func viewWillAppear(_ animated: Bool) {
        setupAnnotations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapPinAction))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            pins = result
            mapView.removeAnnotations(mapView.annotations)
            setupAnnotations()

        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    @objc func tapPinAction(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude.magnitude
            pin.longitude = coordinate.longitude.magnitude
            do {
                try dataController.viewContext.save()
            } catch{
                print("error")
            }
            
            pins.append(pin)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func setupAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
}


extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "mapLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "mapLongitude")
        let zoom = mapView.region.span
        UserDefaults.standard.set(zoom.latitudeDelta, forKey: "mapLatitudeDelta")
        UserDefaults.standard.set(zoom.longitudeDelta, forKey: "mapLongitudeDelta")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController
        
        for pin in pins {
            controller?.pin = pin
        }
        // Passing coordinate to the 2nd screen
        controller?.dataController = dataController
        self.show(controller!, sender: nil)
    }
}
