//
//  PostVC.swift
//  MaterailCopy
//
//  Created by User on 4/8/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import SwiftyJSON


class PostVC: UIViewController {
    
    var posts = [Post]()
    
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache()
    var isImageSelected:Bool = false
    var tableRowHeight = 300
    
    @IBOutlet weak var postTextField: MaterialTextField!
    @IBOutlet weak var postImageView: UIImageView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Tap gesture for the image button
        let pickImagegesture = UITapGestureRecognizer(target: self, action: #selector(takeImage))
        postImageView.userInteractionEnabled = true
        postImageView.addGestureRecognizer(pickImagegesture)
        
        // Image Picker object
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dict: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    

    
    
    func takeImage(selector: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func postButton(sender: UIButton) {
        
        if let post = postTextField.text where postTextField.text != "" {
            
            if let image = postImageView.image where isImageSelected {
                
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                let imageData = UIImageJPEGRepresentation(image, 0.2)
                let keyData = "69BOPQUW3d6f216b30bc2cb34a7a616b53c645ec".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: imageData!, name: "fileupload", fileName: "image", mimeType: "images/jpeg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    }, encodingCompletion: { encodingResult in
                        
                        switch encodingResult {
                            
                        case .Success(let upload, _, _):
                            
                            upload.responseJSON { response in
                                switch response.result {
                                case .Success(let value):
                                    let json = JSON(value)
                                    let imageLink = json["links"]["image_link"]
                                    let imageString = String(imageLink)
                                    print(imageString)
                                    self.postToFirebase(post, imgUrl: imageString)
                                    
                                case .Failure(let error):
                                    print(error)
                                }
                            }
                            break
                        case .Failure(let error):
                            print(error)
                        }
                })
                
            } else {
                postToFirebase(post, imgUrl: nil)
            }
        }
    }
   
    
    func postToFirebase(post: String, imgUrl: String?) {
        
        var post: Dictionary<String, AnyObject> = [
            "description": post,
            "likes": 0
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        isImageSelected = false
        
        postImageView.image = UIImage(named: "pick-photo")
        postTextField.text = ""
        
        tableView.reloadData()
    }
    
}

extension PostVC :    UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        let  cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
        
        var img: UIImage!
        if let url = post.imageUrl {
            img = PostVC.imageCache.objectForKey(url) as? UIImage
        }
        
        cell.configureCell(post, image: img)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
}

extension PostVC :  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        postImageView.image = image
        isImageSelected = true
    }
    
}
