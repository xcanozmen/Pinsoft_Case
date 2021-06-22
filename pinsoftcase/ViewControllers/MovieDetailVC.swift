//
//  MovieDetailVC.swift
//  pinsoftcase
//
//  Created by Can on 16.06.2021.
//
//
import UIKit
import Alamofire
import SwiftyJSON
import FirebaseAnalytics

class MovieDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selectedMovieImdbID = String()
    var selectedMovieIsStar : Bool?

    var activityIndicator = UIActivityIndicatorView(style: .large)

    var movieDetailsArray = [MovieDetails]() {
        didSet {
            DispatchQueue.main.async {
                self.detailTableview.reloadData()
            }
        }
    }

    @IBOutlet weak var detailTableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableview.delegate = self
        detailTableview.dataSource = self
        self.detailTableview.register(UINib.init(nibName: "DetailTableVCell", bundle: nil), forCellReuseIdentifier: "DetailTableVCell")
        activityIndicatorConfigure(activityIndicator : activityIndicator)
        print(selectedMovieImdbID)
        print(selectedMovieIsStar!)

        showActivityIndicator(activityIndicator: self.activityIndicator, tableView: self.detailTableview)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        movieDetailsArray.removeAll(keepingCapacity: false)
        getMovieDetailData(selectedMovieImdbID: selectedMovieImdbID, activityIndicator: activityIndicator, tableView: detailTableview){ ltd in
            self.movieDetailsArray += ltd
            self.addLogFirebase(movie: ltd[0])
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieDetailsArray.count
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
        
        if selectedMovieIsStar == true {
            cell.starImgView.isHidden = false
        } else {
            cell.starImgView.isHidden = true
        }
        return cell
    }

    func addLogFirebase(movie: MovieDetails){
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: movie.imdbID!,
            AnalyticsParameterItemName: movie.title!,
            AnalyticsParameterContentType: movie.actors!,
            AnalyticsParameterScreenName: "MOVIE_DETAİL_VC",
            AnalyticsParameterLocationID: CURRENT_USER_UUID4
          ])
        print("Firebase debug send")
    }

    func activityIndicatorConfigure(activityIndicator : UIActivityIndicatorView) {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.color = .systemBlue
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}


