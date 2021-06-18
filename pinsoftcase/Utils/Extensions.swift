//
//  Extensions.swift
//  pinsoftcase
//
//  Created by Can on 15.06.2021.
//

import Foundation
import UIKit
import CoreData
import Alamofire
import SwiftyJSON

extension UIView {

func round(corners: UIRectCorner, cornerRadius: Double) {
    
    let size = CGSize(width: cornerRadius, height: cornerRadius)
    let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
    let shapeLayer = CAShapeLayer()
    shapeLayer.frame = self.bounds
    shapeLayer.path = bezierPath.cgPath
    self.layer.mask = shapeLayer
    }
}

extension UIViewController{
    
    func getStarMoviesID() -> Array<String>{
        
        var starMovies = [String]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stars")
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(fetchRequest)

            for result in results as! [NSManagedObject]  {
                if let id = result.value(forKey: "id") as? String {
                    starMovies.append(id)
                }
            }
            return starMovies
        }catch{
            print("error")
            return starMovies
        }
    }
    
    @objc func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showUserInteractiveAlert(title: String, msg: String ){
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Hayır", style: .default, handler: { (action: UIAlertAction!) in
              print("Close")
        }))

        refreshAlert.addAction(UIAlertAction(title: "Evet", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Open")
            
        }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    func showActivityIndicator(activityIndicator : UIActivityIndicatorView, tableView : UITableView){
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        tableView.alpha = 0.5
    }
    
    func hideActivityIndicator(activityIndicator : UIActivityIndicatorView, tableView : UITableView){
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
        tableView.alpha = 1
    }
}
