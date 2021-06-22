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
    
    func getMovies(movieName: String, activityIndicator: UIActivityIndicatorView,
                   tableView: UITableView, completionHandler: @escaping (Movie)-> Void){
        
        var movieArray = [Movie]()
    
        URLManager.shared().SetS(val: movieName)
        let reqURL = URLManager.shared().GetTableViewCellDataURL()
        
        AF.request(reqURL, method: HTTPMethod.get).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    if json["Response"].stringValue == "True" {
                        
                        for item in json["Search"].arrayValue {
                            let movie = Movie(title: item["Title"].stringValue,
                                              year: item["Year"].stringValue,
                                              imdbid: item["imdbID"].stringValue,
                                              tur: item["Type"].stringValue,
                                              poster: item["Poster"].stringValue)

                            movieArray.append(movie)
                            completionHandler(movie)
                            
                        }
                        self.hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                    }else if json["Response"].stringValue == "False" {
                        self.hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                        self.showAlert(title: "Film Bulunamadı", msg: "Lütfen başka bir film arayın")
                    }
                }else {
                    self.hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                    self.showAlert(title: "Hata", msg: "Bilinmeyen bir hata oluştu")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getMovieDetailData(selectedMovieImdbID: String, activityIndicator: UIActivityIndicatorView,
                            tableView: UITableView, completionHandler: @escaping (Array<MovieDetails>)-> Void){
        URLManager.shared().SetImdbID(val: selectedMovieImdbID)
        let reqURL = URLManager.shared().GetDetailVCDataURL()
        print(reqURL)
        
        var movieDetailsArray = [MovieDetails]()

        AF.request(reqURL, method: HTTPMethod.get).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    print(json)
                    if json["Response"].stringValue == "True" {

                        var movie = MovieDetails(imdbVotes: json["imdbVotes"].stringValue, country: json["Country"].stringValue, language: json["Language"].stringValue, website: json["Website"].stringValue, metascore: json["Metascore"].stringValue, rated: json["Rated"].stringValue, director: json["Director"].stringValue, boxOffice: json["BoxOffice"].stringValue, year: json["Year"].stringValue, imdbID: json["imdbID"].stringValue, runtime: json["Runtime"].stringValue, awards: json["Awards"].stringValue, released: json["Released"].stringValue, plot: json["Plot"].stringValue, writer: json["Writer"].stringValue, actors: json["Actors"].stringValue, dVD: json["DVD"].stringValue, genre: json["Genre"].stringValue, imdbRating: json["imdbRating"].stringValue, response: json["Response"].stringValue, title: json["Title"].stringValue, production: json["Production"].stringValue, poster: json["Poster"].stringValue, type: json["Type"].stringValue)
                        for item in json["Ratings"].arrayValue{
                            let ratings = Ratings(value: item["Value"].stringValue, source: item["Source"].stringValue)
                            movie.ratings?.append(ratings)
                            
                        }

                        movieDetailsArray.append(movie)
                        completionHandler(movieDetailsArray)
                        
                        self.hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                    }else {
                        self.hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                        self.showAlert(title: "Film Bulunamadı", msg: "Lütfen başka bir film arayın")
                    }
                }else {
                    self.hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                    self.showAlert(title: "Hata", msg: "Bilinmeyen bir hata oluştu")
                }
            case .failure(let error):
                print(error)
                self.hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                self.showAlert(title: "Hata", msg: "Bilinmeyen bir hata oluştu")
            }
        }
    }
    
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
