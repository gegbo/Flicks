//
//  FlicksViewController.swift
//  Flicks
//
//  Created by Grace Egbo on 1/25/16.
//  Copyright © 2016 Grace Egbo. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class FlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource,UISearchBarDelegate{
    
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkError: UIView!
    
    var hidden = true
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

//        tableView.dataSource = self
//        tableView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        //tableView.insertSubview(refreshControl, atIndex: 0)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if let data = dataOrNil
                {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            //self.tableView.reloadData()
                            self.filteredData = self.movies
                            self.collectionView.reloadData()
                            
                    }
                    self.networkError.hidden = true
                }
        })
        task.resume()

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        if (movies == nil)
//        {
//            return 0
//        }
//        print(movies?.count)
        
        if (filteredData == nil)
        {
            return 0
        }
        
        //return (movies?.count)!
        return filteredData.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as!  MovieCell
        
        //let movie = movies![indexPath.row]
        let movie = filteredData![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        
       
        if let posterPath = movie["poster_path"] as? String
        {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
            cell.posterView.setImageWithURL(imageUrl!)
        }
        else
        {
            cell.posterView.image = nil
        }
        

        
        cell.titleLabel.text = title
        cell.overviewLabel.text  = overview
        
        // cell.textLabel!.text = title - not needed anymore since using custom label
        //print("row \(indexPath.row)")
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
//        if (movies == nil)
//        {
//            return 0
//        }
//        print(movies?.count)
        
        if (filteredData == nil)
        {
            return 0
        }
        //print(filteredData?.count)
        
        //return (movies?.count)!
        return filteredData.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("posterView", forIndexPath: indexPath) as! PosterCell
        
        //let movie = movies![indexPath.row]
        let movie = filteredData![indexPath.row]
//        if let posterPath = movie["poster_path"] as? String
//        {
//            let baseUrl = "http://image.tmdb.org/t/p/w500"
//            
//            let imageUrl = NSURL(string: baseUrl + posterPath)
//            
//            cell.posterView.setImageWithURL(imageUrl!)
//        }
//        else
//        {
//            cell.posterView.image = nil
//        }

        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        
        let posterUrl = baseUrl + posterPath
        let imageRequest = NSURLRequest(URL: NSURL(string: posterUrl)!)
        
        cell.posterView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
                cell.posterView.image = nil
        })
        
        return cell
     }

    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let myRequest = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,completionHandler: { (dataOrNil, response, error) in
            
            if(error != nil)
            {
                self.networkError.hidden = false
            }
            else
            {
                self.networkError.hidden = true
            }
                // ... Use the new data to update the data source ...
            if let data = dataOrNil
            {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                        print("response: \(responseDictionary)")
                        
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        //self.tableView.reloadData()
                        self.collectionView.reloadData()
                }
            }

            
                // Reload the tableView now that there is new data
                //self.tableView.reloadData()
                self.collectionView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()	
        });
        task.resume()
    }
    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty
        {
            filteredData = movies
            //collectionView.reloadData()
        }
        else
        {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = movies!.filter({(movie: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
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
