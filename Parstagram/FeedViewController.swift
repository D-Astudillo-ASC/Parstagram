//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Daniel Astudillo on 3/14/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{
    
    var posts = [PFObject]()
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    let refreshControl: UIRefreshControl! = UIRefreshControl()
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    @IBAction func onLogout(_ sender: Any) {
       //let currentUser = PFUser.current()!
        PFUser.logOutInBackground { (error) in
            if error == nil{
                let main = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
                let delegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                delegate?.window?.rootViewController = loginViewController
            }
            else{
                print("error logging out: \(String(describing: error))")
            }
        }
        
    }
    @objc func loadPosts(){
        run(after: 1){
            let query = PFQuery(className: "Posts")
            query.includeKeys(["author","Comments","Comments.author" ])
            query.limit = 20
            query.findObjectsInBackground { (posts, error) in
                if posts != nil{ self.posts.removeAll()
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
            query.includeKeys(["author","Comments","Comments.author" ])
            query.limit = 20
            query.findObjectsInBackground { (posts, error) in
                if posts != nil{
                    self.posts.removeAll()
                    for post in posts!{
                        self.posts.append(post)
                    }
                    self.tableView.reloadData()
                }
                else{
                    print("error loading more posts: \(String(describing: error))")
                    
                }
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create new comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        selectedPost.add(comment, forKey: "Comments")
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("comment saved to post.")
            }
            else{
                print("error saving comment to post: \(String(describing: error))")
            }
        }
        
        tableView.reloadData()
        
        //Clear and dismiss input bar after submitting comment.
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["Comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["Comments"] as? [PFObject]) ??  []
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["Comments"] as? [PFObject]) ?? []
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            let imageFile = post["image"] as! PFFileObject
            let urlStr = imageFile.url!
            let imgUrl = URL(string: urlStr)!
            cell.photoView.af.setImage(withURL: imgUrl)
            return cell
        }
        else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            print("comment: \(comment)")
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  indexPath.section + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        refreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        
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
