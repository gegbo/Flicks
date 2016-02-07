//
//  DetailViewController.swift
//  Flicks
//
//  Created by Grace Egbo on 2/1/16.
//  Copyright © 2016 Grace Egbo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var movie: NSDictionary! 
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Movie Detail"
        navigationItem.leftBarButtonItem?.title = "Movie List"
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        let rating = ((movie["vote_average"] as! Double)*10)
        
        
        ratingLabel.text = String(format: "%.0f", rating)+"%"
        
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String
        {
            let posterUrl = NSURL(string: baseUrl + posterPath)
            posterImageView.setImageWithURL(posterUrl!)
        }
        
        print(movie)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
