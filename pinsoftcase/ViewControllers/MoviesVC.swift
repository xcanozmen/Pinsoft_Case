//
//  MoviesVC.swift
//  pinsoftcase
//
//  Created by Can on 15.06.2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import CoreData
import SDWebImage

class MoviesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    var movieArray = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var starMoviesID = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var choosenMovieImdbId = String()
    var choosenMovieStar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
        
        activityIndicatorConfigure(activityIndicator : activityIndicator)
        showAlert(title: "Bilgi", msg : "Favori eklemek ve silmek için filme basılı tutun")
        
        starMoviesID += getStarMoviesID()
        // Do any additional setup after loading the view.

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.titleLabelView.text = movieArray[indexPath.row].Title
        cell.turLabelView.text = movieArray[indexPath.row].Tur?.uppercased()
        cell.yearLabelView.text = movieArray[indexPath.row].Year
        cell.imgView.sd_setImage(with: URL(string: movieArray[indexPath.row].Poster!), placeholderImage: UIImage(named: "placeholder"))
        
        if starMoviesID.contains(movieArray[indexPath.row].imdbID!) {
            cell.movieStarView.isHidden = false
        } else {
            cell.movieStarView.isHidden = true
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenMovieImdbId = movieArray[indexPath.row].imdbID!
        if starMoviesID.contains(movieArray[indexPath.row].imdbID!) {
            choosenMovieStar = true
        } else {
            choosenMovieStar = false
        }
        performSegue(withIdentifier: "toMovieDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toMovieDetailVC") {
            let selectedIdStar = choosenMovieStar
            let selectedId = choosenMovieImdbId
            if let target = segue.destination as? MovieDetailVC {
                target.selectedMovieIsStar = selectedIdStar
                target.selectedMovieImdbID = selectedId
            }
        }else { }
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        if(searchBar.text != ""){
            if let searchBarText = searchBar.text {
                showActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
                let searchBarTextNoSpace = searchBarText.replacingOccurrences(of: " ", with: "%20")
                print(searchBarTextNoSpace)
                self.getMovies(movieName: searchBarTextNoSpace)
            }
        }else {
            showAlert(title: "Hata", msg: "Aranılacak filmin adını giriniz")
        }
    }
    
    func getMovies(movieName: String){
        
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
                        
                        self.movieArray.removeAll(keepingCapacity: false)
                        
                        for item in json["Search"].arrayValue {
                            let movie = Movie(title: item["Title"].stringValue,
                                              year: item["Year"].stringValue,
                                              imdbid: item["imdbID"].stringValue,
                                              tur: item["Type"].stringValue,
                                              poster: item["Poster"].stringValue)

                            self.movieArray.append(movie)
                            
                        }
                        self.hideActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
                    }else if json["Response"].stringValue == "False" {
                        self.hideActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
                        self.showAlert(title: "Film Bulunamadı", msg: "Lütfen başka bir film arayın")
                    }
                }else {
                    self.hideActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
                    self.showAlert(title: "Hata", msg: "Bilinmeyen bir hata oluştu")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                if(starMoviesID.contains(movieArray[indexPath.row].imdbID!)){
                    if let idString = movieArray[indexPath.row].imdbID {
                        deleteStar(idString: idString, row: indexPath.row)
                        showAlert(title: "Başarılı", msg : "Yıldız silindi")
                    }
                }else {
                    if let id = movieArray[indexPath.row].imdbID {
                        addStar(id: id)
                        showAlert(title: "Başarılı", msg : "Yıldız eklendi")
                    }
                }
            }
        }
    }
    
    func addStar(id : String){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = (appDelegate?.persistentContainer.viewContext)!
        let newProductStar = NSEntityDescription.insertNewObject(forEntityName: "Stars", into: context)
        
        newProductStar.setValue(id, forKey: "id")
        
        do{
            try context.save()
            self.starMoviesID.append(id)
            print("success")
        }
        catch{
            print("error")
        }
        
    }
    
    func deleteStar(idString : String, row : Int){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stars")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? String{
                        if id == idString {
                            context.delete(result)
                            do {
                                try context.save()
                                starMoviesID = starMoviesID.filter { $0 != idString }
                            } catch  {
                                print("error")
                            }
                            break
                        }
                    }
                }
            }
        } catch  {
            print("error")
        }
    }

    func activityIndicatorConfigure(activityIndicator : UIActivityIndicatorView) {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.color = .systemBlue
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}

