//
//  CommunicationDown.swift
//  JeunessebyAnita
//
//  Created by Clement Chan on 10/22/16.
//  Copyright © 2016 Clement Chan. All rights reserved.
//

import Foundation
import Batch
import Firebase

class CommunicationDown:UIViewController{
    
    @IBOutlet weak var entertext: UITextField!

    @IBOutlet weak var communicationboard: UITextView!
    
    @IBOutlet weak var LowerLevel: UILabel!
    @IBOutlet weak var Send: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Back: UILabel!
    
    var messages = [String]()
    var time = [String]()
    var loweremail = [String]()
    
    var ref = FIRDatabase.database().reference()
    
    @IBAction func Distributor(_ sender: AnyObject) {
        if(ProfileLogin.joinlink == ""){
            if let url = NSURL(string: "https://joffice.jeunesseglobal.com/signup.asp?locale=zh-US&siteurl=simplyeffective") {
                UIApplication.shared.openURL(url as URL)
            }
        }
        else{
            if let url = NSURL(string: ProfileLogin.joinlink) {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    @IBAction func Send(_ sender: AnyObject) {
        if(ProfileLogin.password != "" && self.entertext.text != ""){
            
            self.loweremail.removeAll()
            
            let date = NSDate();
            var formatter = DateFormatter();
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
            let defaultTimeZoneStr = formatter.string(from: date as Date);
            
            var message = [
                "message": self.entertext.text! + " " + "--" + ProfileLogin.name,
                "time": "\(defaultTimeZoneStr)"
            ]
            
            //Loading the message query
            ref.child(ProfileLogin.uid).child("Lower").queryLimited(toLast: 10000).observe(.childAdded, with:{ snapshot in
                if let sourceone = snapshot.value as? [String:AnyObject] {
                    let lowemail = sourceone["Lower"] as! String
                    self.loweremail.append(lowemail)
                    
                    for mail in self.loweremail{
                        self.ref.queryOrdered(byChild: "Email").queryEqual(toValue: mail).observe(.childAdded, with: { snapshot in
                            if let source = snapshot.value as? [String:AnyObject] {
                                
                                let uid = source["uid"] as! String
                                self.ref.child(uid).child("Communication").childByAutoId().setValue(message)
                                self.ref.child(ProfileLogin.uid).child("Communication").childByAutoId().setValue(message)
                                
                            }
                        })
                    }
                }
            })
        }
        
        self.entertext.text = "";
    }
    
    
    override func viewDidLoad() {
        
        if(language == "english"){
            language = "english"
            self.LowerLevel.text = "Lower Level"
            self.Send.text = "Send"
            self.Description.text = "User can talk to lower level here"
            self.Back.text = "Back"
        }
        else if(language == "traditional"){
            language = "traditional"
            self.LowerLevel.text = "下層溝通"
            self.Send.text = "發送訊息"
            self.Description.text = "版主可以和下層溝通"
            self.Back.text = "回到前頁"
        }
        else if(language == "simplified"){
            language = "simplified"
            self.LowerLevel.text = "下层沟通"
            self.Send.text = "发送讯息"
            self.Description.text = "版主可以和下层沟通"
            self.Back.text = "回到前页"
        }

        
    //Database Access
        var ref = FIRDatabase.database().reference()
        
        ref.queryOrdered(byChild: "Email").queryEqual(toValue: ProfileLogin.loginemail).observe(.childAdded, with: { snapshot in
            if let source = snapshot.value as? [String:AnyObject] {
                let uid = source["uid"] as! String
                
                //Loading the message query
                ref.child(uid).child("Communication").queryLimited(toLast: 1000).observe(.childAdded, with:{ snapshot in
                    if let sourceone = snapshot.value as? [String:AnyObject] {
                        
                        let message = sourceone["message"] as! String
                        let time = sourceone["time"] as! String
                        
                        self.messages.append(message)
                        self.time.append(time)
                        
                        var finaltext = "";
                        
                        for (ind,time) in zip(self.messages.reversed(),self.time.reversed()){
                            finaltext += ind + "\n" + time + "\n" + "\n";
                        }
                        
                        self.communicationboard.text! = finaltext
                        
                    }
                })
            }
        })
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
};
