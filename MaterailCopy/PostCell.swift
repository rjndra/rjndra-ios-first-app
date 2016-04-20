//
//  PostCell.swift
//  MaterailCopy
//
//  Created by User on 4/8/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    var post: Post!
    var request: Request!
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTapGesture.numberOfTapsRequired = 1
        likeImage.userInteractionEnabled = true
        likeImage.addGestureRecognizer(likeTapGesture)
       
    }
    
    func configureCell(post: Post, image: UIImage?) {
        self.post = post
        
        likeRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        self.postDescription.text = post.postDescription
        self.likeLabel.text = "\(post.like)"
        
        if post.imageUrl != nil {
            
            if image != nil {
                self.postImage.image = image
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: {
                    request, response, data, error in
                                        
                    if error == nil {
                        let img = UIImage(data: data!)
                        self.postImage.image = img
                        PostVC.imageCache.setObject(img!, forKey: self.post.imageUrl!)                    }
                    else { print("<Error> --> \(error)") }
                })
            }
        } else {
            self.postImage?.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value as? NSNull) != nil {
                self.likeImage.image = UIImage(named: "heart-unfilled")
            } else {
                self.likeImage.image = UIImage(named: "heart-filled")
            }
        })
        
    }
    
    func likeTapped(selector: UITapGestureRecognizer) {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value as? NSNull) != nil {
                self.likeImage.image = UIImage(named: "heart-filled")
                self.post.adjustLike(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-unfilled")
                self.post.adjustLike(false)
                self.likeRef.removeValue()
                
            }
        })
    }
    
}
