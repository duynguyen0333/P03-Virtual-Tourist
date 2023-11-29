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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyPhotosLabel: UILabel!
    @IBOutlet weak var newCollectionsButton: UIBarButtonItem!
    
    var coordinate: CLLocationCoordinate2D!
    var photos: [Photo]!
    var pin: Pin!
    var dataController: DataController! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        displaySelectedCoordination()
        fetchPhotosFromStore()
    }
    
    func fetchPhotosFromStore() {
        let predicate = NSPredicate(format: "pin == %@", pin)
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = predicate

        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photos = result
        }  
        
        if photos.isEmpty {
            self.emptyPhotosLabel.isHidden = false
            getCollections()
        } else {
            self.emptyPhotosLabel.isHidden = true
            self.indicator.isHidden = true
        }
    }
    
    @IBAction func newCollectionsAction(_ sender: Any) {
        
        for photo in photos {
            dataController.viewContext.delete(photo)
        }

        try? self.dataController.viewContext.save()
        collectionView.reloadData()
        photos.removeAll()
        getCollections()
    }
    
    func getCollections(){
        showLoading(true)
        emptyPhotosLabel.isHidden = true
        
        Helper.sharedInstance().getPages(coordinate) {(photos, error) in
            if let error = error {
                self.showAlert(title: "Error", message: "\(error.localizedDescription)")
                self.showLoading(false)
            }
            
            if photos.isEmpty {
                DispatchQueue.main.sync {
                    self.emptyPhotosLabel.isHidden = false
                }
            }
            
            for photo in photos {
                guard let url = photo[TouristService.ResponseKeys.URL] as? String else {
                    self.showLoading(false)
                    return
                }
                
                guard let photoData = try? Data(contentsOf: URL(string: url)!) else {
                    self.showLoading(false)
                    return
                }
                
                let photo: Photo = Photo(context: self.dataController.viewContext)
                photo.rawImage = photoData
                photo.source = URL(string: url)
                photo.pin = self.pin
                
                try? self.dataController.viewContext.save()
                self.photos.append(photo)
                
                DispatchQueue.main.async  {
                    self.collectionView.reloadData()
                }
            }
            self.showLoading(false)
            DispatchQueue.main.sync {
                self.collectionView.reloadData()
            }
        }
    }
    
    func displaySelectedCoordination() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func showLoading(_ enable: Bool) {
        if enable {
            self.indicator.startAnimating()
            self.newCollectionsButton.tintColor = .red
            self.newCollectionsButton.isEnabled = false
            indicator?.isHidden = !enable
        } else {
            DispatchQueue.main.sync {
                self.indicator.stopAnimating()
                self.newCollectionsButton.isEnabled = true
                self.indicator?.isHidden = !enable
            }
        }
    }
}
