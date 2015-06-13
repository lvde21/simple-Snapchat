//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Lala Vaishno De on 6/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var row_selected : Int = -1
    
    @IBOutlet var table: UITableView!
    
    var userArray = [String]()
    
    var timer = NSTimer()
    
    
    // MARK : generic alert
    func showAlert(text : String) {
        
        var alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            println("alert shown")
            self.dismissViewControllerAnimated(false, completion: nil)
        }))
        self.presentViewController(alert, animated: false, completion: nil)
    }

    
    
    
    // MARK : opens the camera
    
    func importImage() {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    
    // called when an image is picked by the user
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        println("image selected")
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // upload to Parse
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let imageFile = PFFile(name:"image.png", data:imageData)
        
        var userPhoto = PFObject(className:"Photos")
        userPhoto["from"] = PFUser.currentUser().username
        userPhoto["to"] = userArray[row_selected]
        userPhoto["imageFile"] = imageFile
        userPhoto["Seen"] = false
        
        
        userPhoto.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if(error == nil) {
                self.showAlert("Sent successful")
            } else {
                println("error = \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK - Setting timer to check for new messages
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target : self, selector : Selector("checkingForNewImages"), userInfo : nil, repeats: true)
        
        
        // MARK - Checking for new users
        
        var query = PFUser.query()
        //println("PFUser.currentUser().username = \(PFUser.currentUser().username)")
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)
        query.orderByAscending("username")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if(error == nil) {
                
                if let objects = objects as? [PFUser] {
                    
                    self.userArray.removeAll(keepCapacity: false)
                    
                    for object in objects {
                        
                        self.userArray.append(object.username)
                    }
                }
                println("self.userArray + \(self.userArray)")
                
            } else {
             
                println("Error: \(error!)")
                
            }
            self.table.reloadData()
        }
    }
    
    var timer2 = NSTimer()
    
    func checkingForNewImages() {
        
        println("checking for new messages")
        
        var query = PFQuery(className:"Photos")
        println(PFUser.currentUser().username)
        query.whereKey("to", equalTo: PFUser.currentUser().username)
        query.whereKey("Seen", equalTo: false)
        
        
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            var done = false
            
            if(error == nil) {
                if let objects = objects {
                    println("objects = qq\(objects)")
                
                    for object in objects {
                        if done == false {
                        
                            let oneObject  = object as PFObject

                            // downloading the image
                        
                            var imageView : PFImageView  = PFImageView()
                            imageView.file = oneObject["imageFile"] as PFFile
                            imageView.loadInBackground({ (imageDownloaded, error) -> Void in
                            
                                if(error == nil) {
                                
                                    var fromUser = oneObject["from"] as String
                                
                                    var text : String = "New Message from \(fromUser)"
                                
                                    var alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                                
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                    
                                    println("alert shown")
                                        //self.dismissViewControllerAnimated(false, completion: nil)
                                    
                                    // add background
                                    var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                    backgroundView.backgroundColor = UIColor.blackColor()
                                    backgroundView.alpha = 0.8
                                    backgroundView.tag = 3
                                    self.view.addSubview(backgroundView)
                                    
                                    
                                    
                                    var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                    displayedImage.image = imageDownloaded
                                    displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                    displayedImage.tag = 3
                                    self.view.addSubview(displayedImage)
                                    
                                    println("displaying image")
                                    
                                    //oneObject["Seen"] = true
                                    //oneObject.saveInBackground()
                                    
                                    self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target : self, selector : Selector("hideImage"), userInfo : nil, repeats: false)
                                    
                                }))
                                self.presentViewController(alert, animated: false, completion: nil)
                            }
                        })
                            
                        done = true
                        }
                    }
                }
                
            } else {
                
                println("error = \(error)")
                
            }
            
            
        }
    }
    
    
    // MARK : hides recieved image after 10 seconds
    func hideImage() {
        
        for subview in self.view.subviews {
            
            //timer2.invalidate()
            
            if(subview.tag == 3) {
            
                subview.removeFromSuperview()
            }
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userArray.count
    }

    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        if(userArray[indexPath.row] != PFUser.currentUser().username) {
            cell.textLabel!.text = userArray[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("Selected : \(userArray[indexPath.row])")
        
        row_selected = indexPath.row
        
        importImage()
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "logOutSegue") {
            
            timer.invalidate()
            
            PFUser.logOut()
            
        }
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
