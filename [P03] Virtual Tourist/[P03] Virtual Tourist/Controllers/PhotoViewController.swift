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
    
    var coordinate: CLLocationCoordinate2D!
    var photos: [Photo]!
    var pin: Pin!
    var dataController: DataController!
    let reloadButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customIcon()
        fetchPhotosFromStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displaySelectedCoordination()
        if photos.isEmpty {
            getCollections()
        }
    }
    
    func getCollections(){
        let _ = Helper.sharedInstance().getPages(coordinate) { (photos, error) in
            if let error = error {
                self.showAlert(title: "Error", message: "\(error.localizedDescription)")
            }

            for photo in photos {
                guard let url = photo[TouristService.ResponseKeys.MediumURL] as? String else {
                    return
                }
                
                guard let photoData = try? Data(contentsOf: URL(string: url)!) else {
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
            DispatchQueue.main.sync {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func customIcon(){
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        let rightBarButtonItem = UIBarButtonItem(customView: reloadButton)
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
        self.navigationItem.title = "Albums"
        reloadButton.addTarget(self, action: #selector(reloadCollectionAction), for: .touchUpInside)
    }
    
    @objc func reloadCollectionAction(){
        pin.photos = nil
        try? self.dataController.viewContext.save()
        collectionView.reloadData()
        photos.removeAll()
        getCollections()
    }
    
    func fetchPhotosFromStore() {
        let predicate = NSPredicate(format: "pin == %@", pin)
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = predicate
        
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photos = result
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
}
