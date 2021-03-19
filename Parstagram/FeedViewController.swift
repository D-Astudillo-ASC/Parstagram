//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Daniel Astudillo on 3/14/21.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var posts = [PFObject]()
    //var numberOfPosts : Int!
    let refreshControl: UIRefreshControl! = UIRefreshControl()
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    @IBAction func onLogout(_ sender: Any) {
       //let currentUser = PFUser.current()!
        PFUser.logOutInBackground { (error) in
            if error == nil{
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print("error logging out: \(String(describing: error))")
            }
        }
        
        
    }
    @objc func loadPosts(){
        run(after: 1){
            let query = PFQuery(className: "Posts")
            query.includeKey("author")
            query.limit = 10
            //self.numberOfPosts = 10
            query.findObjectsInBackground { (posts, error) in
                if posts != nil{
                    print("posts loaded: \(String(describing: posts))")
                    self.posts.removeAll()
                    self.posts = posts!
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
                else{
                    print("error loading posts: \(String(describing: error))")
                }
            }
        }
    }
    
    func loadMorePosts(){
        run(after: 1){
            let query = PFQuery(className: "Posts")
            query.includeKey("author")
            query.limit = 10
            //numberOfPosts += 10
            query.findObjectsInBackground { (posts, error) in
                if posts != nil{
                    print("more posts loaded: \(String(describing: posts))")
                    for post in posts!{
                        self.posts.append(post)
                    }
                    self.tableView.reloadData()
                    //self.refreshControl.endRefreshing()
                }
                else{
                    print("error loading more posts: \(String(describing: error))")
                    //reset number of posts.
                    //self.numberOfPosts = 0
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as? String
        let imageFile = post["image"] as! PFFileObject
        let urlStr = imageFile.url!
        let imgUrl = URL(string: urlStr)!
        cell.photoView.af.setImage(withURL: imgUrl)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @IBOutlet var tableView: UITableView!
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
