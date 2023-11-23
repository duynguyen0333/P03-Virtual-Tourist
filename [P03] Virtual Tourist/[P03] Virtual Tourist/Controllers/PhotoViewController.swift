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

class PhotoViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var coordinate: CLLocationCoordinate2D!
    var photos: [Photo]!
//    lazy var photos = pin.photos!.allObjects as! [Photo]

    var pin: Pin!
    var dataController: DataController!
    var page: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.isHidden = true
//        setUpCollectionView()
        setStaticMapView()

//        if(photos?.count == 0) {
//            reloadData()
//        }
        TouristService.getPhotos(lat: pin.latitude, lon: pin.longitude, page: page, completionHandler: photoSearchResponse(response:error:))
        
    }
    
    @IBAction func reloadData() {
        page += 1
        pageLoading(loading: true)

        TouristService.getPhotos(lat: pin.latitude, lon: pin.longitude, page: page, completionHandler: photoSearchResponse(response:error:))
    }
    
    func reloadPhotos(){
        collectionView!.reloadData()
    }
    
    func photoSearchResponse(response: TouristPhotos?, error: Error?) -> Void {
        if let response = response {
            photos = []
            let newPhoto = Photo(context: self.dataController.viewContext)
            
            if response.photos.photo.count > 0 {
                warningLabel.isHidden = true
            } else {
                warningLabel.isHidden = false
            }
            
            for photo in response.photos.photo {
                TouristService.getSizes(photoId: photo.id) {(response, error) in
                    if let response = response {
                        self.warningLabel.isHidden = true
                        
                        if let addedPhoto = response.sizes.size.first  {
                            print("GetSize Photo \(addedPhoto.source)")
                            
                            newPhoto.id = photo.id
                            newPhoto.source = URL(string: addedPhoto.source)!
                            
                            self.pin.addToPhotos(newPhoto)
                            try? self.dataController.viewContext.save()
                            self.photos = (self.pin.photos!.allObjects as! [Photo])
                            self.reloadPhotos()

                        }
                    } else {
                        self.warningLabel.isHidden = false
                    }
                }
            }
        } else {
            self.warningLabel.isHidden = false
            pageLoading(loading: false)
        }
        
    }
    
    func pageLoading(loading: Bool) {
        warningLabel.isEnabled = !loading
    }
    
//    func setUpCollectionView() {
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView!.reloadData()
//    }

    func setStaticMapView() {
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
}


extension PhotoViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width/4.0
        let height = width

        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let photo = photos[(indexPath).row]
//        print("Current photo \(photo)")
    
        if let source = photo.source {
            TouristService.downloadImage(url: source) {(url, error) in
                if let url = url {
                    let downloadedImage = UIImage(data: url)
                    if let downloadedImage = downloadedImage {
                        cell.imageView.image = downloadedImage
                    }
                }
            }
        }
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[(indexPath as NSIndexPath).row]
        pin.removeFromPhotos(photo)
        try? dataController.viewContext.save()
        reloadPhotos()
    }
}
