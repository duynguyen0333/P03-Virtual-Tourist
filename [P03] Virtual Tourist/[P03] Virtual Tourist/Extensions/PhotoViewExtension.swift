//
//  PhotoViewExtension.swift
//  [P03] Virtual Tourist
//
//  Created by aia on 27/11/2023.
//

import Foundation
import UIKit
import MapKit

extension PhotoViewController {
    func showAlert(title: String,message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true)
    }
    
    // MARK: Delegate Function
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
//        if let rawImage = photos[indexPath.row].rawImage {
//            cell.imageView.image = UIImage(data: rawImage )
//        }
        
        // Set the placeholder image initially
        cell.imageView.image = UIImage(named: "placeholder")
        
        // Start the image download
        let imageURL = URL(string: "https://example.com/image.jpg")!
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let data = data {
                // Replace the placeholder image with the downloaded image
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
            }
        }.resume()
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
//        
//        // Set the placeholder image initially
//        cell.imageView.image = UIImage(named: "placeholder")
//        
//        // Start the image download
//        let imageURL = URL(string: "https://example.com/image.jpg")!
//        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
//            if let data = data {
//                // Replace the placeholder image with the downloaded image
//                DispatchQueue.main.async {
//                    cell.imageView.image = UIImage(data: data)
//                }
//            }
//        }.resume()
//    }
//    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.delete(photos[indexPath.row])
        try? self.dataController.viewContext.save()
        photos.remove(at: indexPath.row)
        
        if photos.isEmpty {
            self.emptyPhotosLabel.isHidden = false
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2*space)) / 3.0
        
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
