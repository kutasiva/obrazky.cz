//
//  ViewController.swift
//  iHledej
//
//  Created by kutasov on 14/01/15.
//  Copyright (c) 2015 kutasov. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITextFieldDelegate, UIActionSheetDelegate  {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var seacrText: UITextField!
    
    var imagesSize = [String]()
    var imagesUrl = [NSURL]()
    var imagesUrlCache :[Int: UIImage] = Dictionary()
    var fullImage: UIImageView = UIImageView()
    var actCell :ImageViewCell? = nil
    
    var nImage: Int = 0
    var imageMaxScale: CGFloat = 4.0
    var imageMinScale: CGFloat = 1.0
    var imageCurrentScale: CGFloat = 1.0
    
    var isSwapped: Bool = false
    
    @IBAction func searcRun(sender: AnyObject) {
        imagesUrlCache.removeAll(keepCapacity: false)
        seacrText.resignFirstResponder()
        self.getImages()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        var cell = webView.superview?.superview as ImageViewCell
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        imagesUrlCache.removeAll(keepCapacity: false)
        textField.resignFirstResponder()
        self.getImages()
        println(self.tableView)
        return true;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isSwapped = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        nImage = indexPath.row
        self.fullImage.contentMode = UIViewContentMode.ScaleAspectFit
        var image:UIImage? = getImage()

        let cell :ImageViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ImageViewCell
        println("select cell \(cell) for indexPath.row - \(indexPath.row)")
        self.fullImage.clipsToBounds = true
        self.fullImage.userInteractionEnabled = true
        self.fullImage.backgroundColor = UIColor.whiteColor()
        self.fullImage.image = image
        
        self.fullImage.frame = CGRectMake(view.center.x - (imageHeight/2) , imageTopSpace + (cell.frame.origin.y), imageWidth, imageHeight)
       
        UIView.transitionWithView(self.view, duration: 0.4, options: UIViewAnimationOptions.AllowUserInteraction, animations:{
            self.fullImage.frame = self.view.bounds
            self.view.addSubview(self.fullImage)
            tableView.scrollEnabled = false
            tableView.allowsSelection = false
            self.seacrText.hidden = true
            }, completion: { (fininshed: Bool) -> () in
                self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.fullImage.backgroundColor = UIColor.blackColor()
                
                var doneButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneAction:")
                var shareButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareAction:")
                self.navigationItem.leftBarButtonItem = doneButton
                self.navigationItem.rightBarButtonItem = shareButton

                var tgr:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
                var swipeLeft :UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
                swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
                var swiperight :UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
                swiperight.direction = UISwipeGestureRecognizerDirection.Right
                
                var pinch : UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
                
                self.fullImage.addGestureRecognizer(pinch)
                self.fullImage.addGestureRecognizer(tgr)
                self.fullImage.addGestureRecognizer(swipeLeft)
                self.fullImage.addGestureRecognizer(swiperight)
        })
    }
    
    func makeTransationOnView(view:UIImageView, right: Bool) {
        var moveImageView : UIImageView = self.fullImage
        var transation :CATransition = CATransition()
        transation.duration = 0.3
        transation.type = kCATransitionPush
        if right == true {
            transation.subtype = kCATransitionFromRight
        } else {
             transation.subtype = kCATransitionFromLeft
        }
        
        transation.fillMode = kCAFillModeForwards
        transation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        fullImage.superview?.layer .addAnimation(transation, forKey: nil)
    }
    
    func getImage() -> UIImage {
        var image:UIImage? = imagesUrlCache[nImage]
        if image == nil {
            var data:NSData? = NSData(contentsOfURL: imagesUrl[nImage])
            if data == nil {
                image = UIImage(named: "noImages.jpg")!
            } else {
                image = UIImage(data: data!)
                imagesUrlCache[nImage] = image
            }
        }
        return image!
    }
    
    func shakeViewFullImage() {
        var shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        var from_point:CGPoint = CGPointMake(fullImage.center.x - 10, fullImage.center.y)
        var from_value:NSValue = NSValue(CGPoint: from_point)
        
        var to_point:CGPoint = CGPointMake(fullImage.center.x + 10, fullImage.center.y)
        var to_value:NSValue = NSValue(CGPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        fullImage.layer.addAnimation(shake, forKey: "position")
    }
    
    
    // MARK: Gesture recognizer
    
    func handlePinch(gesture:UIPinchGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Changed || gesture.state == UIGestureRecognizerState.Began {
            if(imageCurrentScale * gesture.scale > imageMinScale && imageCurrentScale * gesture.scale < imageMaxScale) {
            println("xxxxx")
            imageCurrentScale = imageCurrentScale * gesture.scale
            println(imageCurrentScale)
            println(gesture.view?.frame)
            var zoom :CGAffineTransform = CGAffineTransformMakeScale(imageCurrentScale, imageCurrentScale)
            println(imageCurrentScale)
            gesture.view?.transform = zoom
            gesture.scale = 1.0
            }
        }
        if gesture.state == UIGestureRecognizerState.Ended {
            var zoom :CGAffineTransform = CGAffineTransformMakeScale(1.0, 1.0)
            imageCurrentScale = 1.0
            println(imageCurrentScale)
            gesture.view?.transform = zoom
        }
    }
    
     func handleSwipe(swipe:UISwipeGestureRecognizer) {
        isSwapped = true
        if swipe.direction == UISwipeGestureRecognizerDirection.Left {
            if nImage + 1 < imagesUrl.count {
                nImage++
                self.makeTransationOnView(fullImage, right: true)
                self.fullImage.image = getImage()
        
            } else {
                self.shakeViewFullImage()
            }
        }
        if swipe.direction == UISwipeGestureRecognizerDirection.Right {
            if nImage > 0 {
                nImage--
                self.makeTransationOnView(fullImage, right: false)
                self.fullImage.image = getImage()
            } else {
                self.shakeViewFullImage()
            }
        }
    }
    
    func handleTap(tgr:UITapGestureRecognizer){
        if self.navigationController?.navigationBar.tintColor == UIColor.blackColor() {
            self.navigationBar.leftBarButtonItem?.enabled = true
            self.navigationBar.rightBarButtonItem?.enabled = true
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
            
        } else {
            self.navigationBar.leftBarButtonItem?.enabled = false
            self.navigationBar.rightBarButtonItem?.enabled = false
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        }
    }
    
    // MARK: - Navigation bar buttons
    func doneAction(sender: AnyObject) {
        self.fullImage.backgroundColor = UIColor.whiteColor()
        self.tableView.allowsSelection = true
        self.tableView.scrollEnabled = true
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        self.navigationBar.leftBarButtonItem = nil
        self.seacrText.hidden = false
        
        var searchButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searcRun:")

        if isSwapped == true {
            //TODO: cell.heigth = 255, topBarHeight = 64
            self.fullImage.frame = CGRect(x:0.0, y: ( (255 * CGFloat(self.nImage)) - 64), width: view.bounds.width, height: view.bounds.height)
        }
        
        self.navigationItem.rightBarButtonItem = searchButton
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{
            self.fullImage.frame = CGRectMake(self.view.center.x - (imageHeight/2) , (imageTopSpace + (255 * CGFloat(self.nImage))), imageWidth, imageHeight)
            }, completion: { (fininshed: Bool) -> () in
            self.fullImage.removeFromSuperview()
        })
        let indexPath = NSIndexPath(forRow: nImage, inSection: 0)
        if isSwapped == true  {
            if nImage == imagesUrl.count {
                println("last object nImage -  \(nImage) and imagesUrl.count \(imagesUrl.count)")
                let indexPath = NSIndexPath(forRow: nImage - 1, inSection: 0)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
        isSwapped = false
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var image :UIImage = getImage()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    func shareAction(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save to My Photos ")
        actionSheet.showInView(self.view)
    }
    
    // MARK: - Table View Data
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if imagesUrl.count == 0 {
            self.tableView.separatorColor = UIColor.clearColor()
        } else {
           self.tableView.separatorColor = UIColor.grayColor()
        }
        
        return imagesUrl.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> ImageViewCell {
        var cell:ImageViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as ImageViewCell
        println("index.row = \(indexPath.row)")
        if imagesUrl.count != 0 {
            cell.tag = indexPath.row
            cell.imageView?.image = nil
            cell.sizeLabel.text = self.imagesSize[indexPath.row]
            
            var strWeb :NSString = self.imagesUrl[indexPath.row].absoluteString!
            
            cell.webLabel.text = (strWeb as NSString).substringToIndex(20)
            
            var img:UIImage? = imagesUrlCache[indexPath.row]
            if img != nil {
                cell.imageView?.image = img
                println("cell - \(cell) with tag  - \(cell.tag) get image - \(img)  from cache")
            } else {
                println("new Image -> load wrom url")
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    var data:NSData? = NSData(contentsOfURL: self.imagesUrl[indexPath.row])
                    var  image:UIImage?
                    if data == nil {
                        image = UIImage(named: "noImages.jpg")
                    } else {
                        image = UIImage(data: data!)
                    }
                    println("get new image - \(image) for indexpath.row -\(indexPath.row)")
                    dispatch_async(dispatch_get_main_queue()) {
                        println("dispatch_async")
                        if image != nil {
                            self.imagesUrlCache[indexPath.row] = image
                            println("save naew image - \(image) for indexpath.row -\(indexPath.row) in imagesUrlCache[\(indexPath.row)] ")
                            var cellForActImage : ImageViewCell? = self.tableView.cellForRowAtIndexPath(indexPath) as? ImageViewCell
                            if cellForActImage != nil {
                                println("set image - \(image) on cell tag \(cellForActImage?.tag)")
                                cellForActImage?.imageView?.image = image
                                cellForActImage?.setNeedsLayout()
                            }
                        }
                    }
                }
            }
        }
        return cell as ImageViewCell
    }
    
    // save images url
    func getImages() {
        // TODO: use objective c regex
        imagesUrl.removeAll(keepCapacity: false)
        var str = seacrText.text
        if let strEnc = str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let url = NSURL(string: NSString(format: "http://obrazky.cz/searchAjax?q=%@&s=&size=any&color=any&filter=true", strEnc))
            //println("url  =  \(url)")
            let request = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                var error: NSError?
                var datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
                println(datastring)
                
                let sourceArray :AnyObject = (datastring?.componentsSeparatedByString("data-dot=\\\""))! as NSArray
                for var index = 1; index < sourceArray.count; index++ {
                    let imgUrl :AnyObject = (sourceArray[index]?.componentsSeparatedByString("\\"))!
                    let url :NSURL = NSURL(string: imgUrl[0] as NSString)!
                    self.imagesUrl.append(url)
                }
                
                let sizeArray :AnyObject = (datastring?.componentsSeparatedByString("<span>"))! as NSArray

                 println(sizeArray)
                 for var index = 1; index < sizeArray.count; index++ {
                    let sizeA :AnyObject = (sizeArray[index]?.componentsSeparatedByString("</span>"))!
                    let size :String = sizeA[0] as String
                    self.imagesSize.append(size)
                }
                self.tableView.reloadData()
            }
        }
    }




}





