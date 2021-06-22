//
//  URLManager.swift
//  pinsoftcase
//
//  Created by Can on 16.06.2021.
//

import Foundation


class URLManager {
    
    private static var reqURL : URLManager?
    
    private let BASE_URL = "https://www.omdbapi.com/"
    private let API_KEY = "1e6b0baf"
    private var s : String? = nil
    private var ImdbID : String? = nil
    
    private init(){ }
    
    class func shared() -> URLManager {
        
        if (reqURL == nil){
            reqURL = URLManager()
        }
        return reqURL!
    }
    
    func SetS(val: String){
        s = val
    }
    
    func SetImdbID(val: String){
        ImdbID = val
    }
    
    func GetTableViewCellDataURL() -> String {
        return "\(BASE_URL)?apikey=\(API_KEY)&s=\(s!)&r=json"
    }
    
    func GetDetailVCDataURL() -> String {
        return "\(BASE_URL)?apikey=\(API_KEY)&i=\(ImdbID!)"
    }
    
}
