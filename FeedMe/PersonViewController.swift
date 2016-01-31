//
//  ImageViewController.swift
//  FeedMe
//
//  Created by Airing on 16/1/27.
//  Copyright © 2016年 Airing. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy

class PersonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /*
    "result": 1,
    "url": "http://121.42.195.113/feedme/images/face2.png"
    */
    struct Response: JSONJoy {
        let result: Int?
        let url: String?
        init(_ decoder: JSONDecoder) {
            result = decoder["result"].integer
            url = decoder["url"].string
        }
    }

    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var imgUserHead: UIImageView!
    @IBOutlet weak var btnUserHead: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            print("read album error")
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        btnUserHead.setBackgroundImage(image, forState: UIControlState.Normal)
        btnUserHead.layer.masksToBounds = true
        btnUserHead.layer.cornerRadius = 50
        
        var data: NSData
        var mimeType: String
        var fileName: String
        
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, 1)!;
            mimeType = "image/jpeg"
            fileName = "head_" + ".jpg"
        } else {
            data = UIImagePNGRepresentation(image)!;
            mimeType = "image/png"
            fileName = "head_" + ".png"
        }
        
        do {
            let request = HTTPTask()
            
            request.POST("http://121.42.195.113/feedme/upload_head.action", parameters:  ["upload": HTTPUpload(data: data, fileName: fileName, mimeType: mimeType)], completionHandler: {(response: HTTPResponse) in
                if let res: AnyObject = response.responseObject {
                    let json = Response(JSONDecoder(res))
                    if (json.result == 1) {
                        print(json.url!)
                        
//                        let url : NSURL = NSURL(string: json.url!)!
//                        let data : NSData = NSData(contentsOfURL:url)!
//                        let image = UIImage(data:data, scale: 1.0)
//                        self.imgUserHead.image = image
//                        self.imgUserHead.layer.masksToBounds = true
//                        self.imgUserHead.layer.cornerRadius = 50
                    } else {
                        print("error")
                    }
                }
            })
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}