//
//  ViewController.swift
//  pinsoftcase
//
//  Created by Can on 15.06.2021.
//

import UIKit

class SplashVC: UIViewController {
    
    var isConnect = false
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "pinsoft")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        isConnect = checkNetworkConnection()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isConnect{
            showAlert(title: "Hata", msg: "Internet baglantısı bulunamadı daha sonra tekrar deneyin")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        if isConnect{
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                self.animate()
            })
        }
    }
    private func animate() {
        UIView.animate(withDuration: 2, animations: {
            let size = self.view.frame.size.width * 2
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(
                x: -(diffX/2),
                y: diffY/2,
                width: size,
                height: size
            )
        },completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                    if self.isConnect{
                        self.performSegue(withIdentifier: "toMoviesVC", sender: nil)
                    }
                })
            }
        })
    }

    func checkNetworkConnection() -> Bool {
        if NetworkMonitor.shared.isConnected {
            print("isConnect true")
            return true
        }else {
            print("isConnect false")
            return false
        }
    }
}
