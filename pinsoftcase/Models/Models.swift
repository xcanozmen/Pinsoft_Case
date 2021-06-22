//
//  Models.swift
//  pinsoftcase
//
//  Created by Can on 16.06.2021.
//

import Foundation

struct Movie {
    var Title: String? = nil
    var Year: String? = nil
    var imdbID: String? = nil
    var Tur: String? = nil
    var Poster: String? = nil
    
    init(title: String?, year: String?,
         imdbid: String?, tur: String?,
            poster: String?){
        self.Title = title
        self.Year = year
        self.imdbID = imdbid
        self.Tur = tur
        self.Poster = poster
    }
}

struct MovieDetails {
    var imdbVotes : String?
    var country : String?
    var language : String?
    var website : String?
    var metascore : String?
    var rated : String?
    var director : String?
    var boxOffice : String?
    var year : String?
    var imdbID : String?
    var runtime : String?
    var awards : String?
    var released : String?
    var plot : String?
    var writer : String?
    var actors : String?
    var dVD : String?
    var genre : String?
    var imdbRating : String?
    var response : String?
    var title : String?
    var production : String?
    var poster : String?
    var type : String?
    var ratings : [Ratings]?

    init(imdbVotes: String, country: String,
         language: String, website: String,
         metascore: String, rated: String,
         director: String, boxOffice: String,
         year: String, imdbID: String,
         runtime: String, awards: String,
         released: String, plot: String,
         writer: String, actors: String,
         dVD: String, genre: String,
         imdbRating: String, response: String,
         title: String, production: String,
         poster: String, type: String){
        
        self.imdbVotes = imdbVotes
        self.country = country
        self.language = language
        self.website = website
        self.metascore = metascore
        self.rated = rated
        self.director = director
        self.boxOffice = boxOffice
        self.year = year
        self.imdbID = imdbID
        self.runtime = runtime
        self.awards = awards
        self.released = released
        self.plot = plot
        self.writer = writer
        self.actors = actors
        self.dVD = dVD
        self.genre = genre
        self.imdbRating = imdbRating
        self.response = response
        self.title = title
        self.production = production
        self.poster = poster
        self.type = type
    }
}

struct Ratings {
    let value : String?
    let source : String?
    
    init(value: String, source: String){
        self.value = value
        self.source = source
    }
}



class MovieToBeAdded {
    
    private static var movieToBeAdded : MovieToBeAdded?
    
    var id : String? = nil
    var name : String? = nil
    var writer : String? = nil
    var imageUrl : String? = nil
    var epocTime : String? = nil
    
    class func shared() -> MovieToBeAdded {
        
        if (movieToBeAdded == nil){
            movieToBeAdded = MovieToBeAdded()
        }
        return movieToBeAdded!
    }
    
    func SetPropertys(name: String, writer: String, imageUrl: String,Id: String, epocTime: String){
        self.name = name
        self.writer = writer
        self.imageUrl = imageUrl
        self.id = Id
        self.epocTime = epocTime
    }
    
    func SetNewStorageUrl(storageURL: String){
        self.imageUrl = storageURL
    }
    
    
    func toDictionary() -> [String: String?] {
        return ["id": self.id, "name": self.name,
                    "type": self.writer,"imageUrl": self.imageUrl,
                    "epocTime": self.epocTime]
    }
    
}
