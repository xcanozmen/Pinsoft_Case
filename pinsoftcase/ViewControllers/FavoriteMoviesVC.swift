//
//  FavoriteMoviesVC.swift
//  pinsoftcase
//
//  Created by Can on 17.06.2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import FirebaseDatabase
import FirebaseStorage

class FavoriteMoviesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    var movieDetailsArray = [MovieDetails]() {
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
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "DetailTableVCell", bundle: nil), forCellReuseIdentifier: "DetailTableVCell")
        activityIndicatorConfigure(activityIndicator: activityIndicator)
        ref = Database.database(url: BASE_URL).reference()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        starMoviesID.removeAll(keepingCapacity: false)
        movieDetailsArray.removeAll(keepingCapacity: false)
        starMoviesID += getStarMoviesID()
        getAllStarsMovieData(starMovies: starMoviesID)
        print("starlı item count\(starMoviesID.count)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieDetailsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableVCell", for: indexPath) as! DetailTableVCell

        cell.nameLabel.text = movieDetailsArray[indexPath.row].title!
        cell.typeLabel.text = movieDetailsArray[indexPath.row].type!
        cell.imgView.sd_setImage(with: URL(string: movieDetailsArray[indexPath.row].poster!), placeholderImage: UIImage(named: "placeholder"))
        cell.labelOne.text = "Genre : \(movieDetailsArray[indexPath.row].genre!)"
        cell.labelTwo.text = "Director : \(movieDetailsArray[indexPath.row].title!)"
        cell.labelThree.text = "Writer : \(movieDetailsArray[indexPath.row].writer!)"
        cell.labelFour.text = "imdbVotes : \(movieDetailsArray[indexPath.row].imdbVotes!)"
        cell.labelFive.text = "imdbRating : \(movieDetailsArray[indexPath.row].imdbRating!)"
        
        if starMoviesID.contains(movieDetailsArray[indexPath.row].imdbID!) {
            cell.starImgView.isHidden = false
        } else {
            cell.starImgView.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let timeInterval = NSDate().timeIntervalSince1970
        MovieToBeAdded.shared().SetPropertys(name: movieDetailsArray[indexPath.row].title!,
                                             writer: movieDetailsArray[indexPath.row].writer!,
                                             imageUrl: movieDetailsArray[indexPath.row].poster!,
                                             Id: movieDetailsArray[indexPath.row].imdbID!,
                                             epocTime: String(format: "\(timeInterval)", self))
        guard let cell = tableView.cellForRow(at: indexPath) as? DetailTableVCell
             else{ return }
                // TODO :core animate the image view
        let image = cell.imgView.image! //you can use this object to animate image view of cell
        
        showActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
        
        uploadImagePic(img1: image, id: movieDetailsArray[indexPath.row].imdbID!)
    }
    
    func uploadImagePic(img1: UIImage, id: String){
            var data = NSData()
        data = img1.jpegData(compressionQuality: 0.8)! as NSData
            // set upload path
            let filePath = "\(id)" // path where you wanted to store img in storage
        let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
        let storage = Storage.storage()
        let storageReference = storage.reference()
        storageReference.child(filePath).putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                storageReference.child(filePath).downloadURL(completion: { (url: URL?, error: Error?) in
                    print(url!.absoluteString) // <- Download URL
                    self.addMovieToDatabase(imgURL: url!.absoluteString)
                })
            }
        }
    }
    
    func addMovieToDatabase(imgURL: String){
        MovieToBeAdded.shared().SetNewStorageUrl(storageURL: imgURL)
        let id = MovieToBeAdded.shared().id!
        ref.child("products/\(id)").setValue(MovieToBeAdded.shared().toDictionary())
        
        hideActivityIndicator(activityIndicator: activityIndicator, tableView: tableView)
        showAlert(title: "Başarılı", msg : "Ürün database'e eklendi")
    }
    
    func getAllStarsMovieData(starMovies: Array<String>){
        
        starMovies.forEach { (movieID) in
            showActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
            
            getMovieDetailData(movieName: movieID)
        }
    }
    
    func getMovieDetailData(movieName: String){
        URLManager.shared().SetImdbID(val: movieName)
        let reqURL = URLManager.shared().GetDetailVCDataURL()

        AF.request(reqURL, method: HTTPMethod.get).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    if json["Response"].stringValue == "True" {

                        var movie = MovieDetails(imdbVotes: json["imdbVotes"].stringValue, country: json["Country"].stringValue, language: json["Language"].stringValue, website: json["Website"].stringValue, metascore: json["Metascore"].stringValue, rated: json["Rated"].stringValue, director: json["Director"].stringValue, boxOffice: json["BoxOffice"].stringValue, year: json["Year"].stringValue, imdbID: json["imdbID"].stringValue, runtime: json["Runtime"].stringValue, awards: json["Awards"].stringValue, released: json["Released"].stringValue, plot: json["Plot"].stringValue, writer: json["Writer"].stringValue, actors: json["Actors"].stringValue, dVD: json["DVD"].stringValue, genre: json["Genre"].stringValue, imdbRating: json["imdbRating"].stringValue, response: json["Response"].stringValue, title: json["Title"].stringValue, production: json["Production"].stringValue, poster: json["Poster"].stringValue, type: json["Type"].stringValue)
                        for item in json["Ratings"].arrayValue{
                            let ratings = Ratings(value: item["Value"].stringValue, source: item["Source"].stringValue)
                            movie.ratings?.append(ratings)
                        }
                        
                        self.movieDetailsArray.append(movie)
                        
                        self.hideActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
                    }
                    self.hideActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
                }
                self.hideActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.tableView)
            case .failure(let error):
                print(error)
            }
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


