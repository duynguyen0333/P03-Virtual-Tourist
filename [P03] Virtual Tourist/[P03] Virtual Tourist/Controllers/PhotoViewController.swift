//
//  PhotoViewController.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 21/11/2023.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var warningLabel: UILabel!
    
    var coordinate: CLLocationCoordinate2D!
    var photos: [Photo]! = []
    var pin: Pin!
    var dataController: DataController!
    var page: Int = 0
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.isHidden = true
//        setupLayout()
        setupMapView()
        
        let predicate =  NSPredicate(format: "pin == %@", pin)
        let fetchRequest:NSFetchRequest<Photo > = Photo.fetchRequest()
        fetchRequest.predicate = predicate
        if let response = try? dataController.viewContext.fetch(fetchRequest) {
            photos = response
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView?.reloadData()
        
        if photos.isEmpty {
            photoResponse()
        }
    }
    
    @IBAction func loadPhotos() {
        page += 1
        pageLoading(loading: true)

//        TouristService.getPhotos(lat: pin.latitude, lon: pin.longitude, page: page, completionHandler: photoSearchResponse(response:error:))
    }
    
    func photoResponse() {
        let _ = TouristService.sharedInstance().getSearchPhotos(coordinate) { (response, error )in
            print(response)
            for image in response {
                guard let imagePath = image[TouristService.ResponseKeys.MediumURL] as? String else {
                    return
                }
                
                let imageURL = URL(string: imagePath)
                
                guard let imageData = try? Data(contentsOf: imageURL!) else {
                    return
                }
                
                let photo: Photo = Photo(context: self.dataController.viewContext)
                photo.source = imageURL
                photo.pin = self.pin
                photo.rawImage = imageData
                
                try? self.dataController.viewContext.save()
                self.photos.append(photo)
                
                DispatchQueue.main.sync {
                    self.collectionView.reloadData()
                }
            }
            
            print("End download")
            DispatchQueue.main.sync {
                self.collectionView.reloadData()
            }
        }
    }

    func setupLayout() {
        collectionView.backgroundColor = .white

        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

    func setupMapView() {
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        let cordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = cordinate
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        
        let rectangleSide = 5000
        let region = MKCoordinateRegion( center: cordinate, latitudinalMeters: CLLocationDistance(exactly: rectangleSide)!, longitudinalMeters: CLLocationDistance(exactly: rectangleSide)!)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    // MARK: Delegate functiion
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .systemTeal
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        if let photo = photos[(indexPath).row].rawImage {
            cell.imageView.image = UIImage(data: photo)
        }
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.delete(photos[indexPath.row ])
        try? self.dataController.viewContext.save()
        photos.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = collectionView.bounds
        
        return CGSize(width: (bounds.width/2)-4, height: bounds.height/2)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top:2, left:2, bottom:2, right:2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func pageLoading(loading: Bool) {
        warningLabel.isEnabled = !loading
    }
    
}
