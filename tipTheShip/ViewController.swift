//
//  ViewController.swift
//  tipTheShip
//
//  Created by Marla Wallerstein on 7/10/15.
//  Copyright © 2015 Jonah Patinkin. All rights reserved.
//
import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var yourScore: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var replayButtonActions: UIButton!
   
    
    var floor = UIView()
    var dynamicAnimator = UIDynamicAnimator()
    var playerDynamicAnimator = UIDynamicAnimator()
    var animator:UIDynamicAnimator? = nil
    var floorAngle = 100.0
    var player = UIView()
    
    
    var drops:[UIView] = []
    var jumpController = 0
    var tipTime : NSTimeInterval = 7
    var resistance = 1000000000
    var xpos = 3
    var score = 0
    var spawnPoint:CGPoint!
    var gravity = UIGravityBehavior()
    var canSpawn = false
    var canSpawn2 = true
    var chnageGravity = false
    var highscore = 0
    var objectSpeed : NSTimeInterval = 1
    let defaults = NSUserDefaults.standardUserDefaults()
    var collisionBehavior = UICollisionBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       gameOverLabel.text = ""
        yourScore.text = ""
        highScoreLabel.text = ""
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        replayButtonActions.enabled = false
        replayButtonActions.hidden = true
        
        //add a floor to the view
        floor = UIView(frame: CGRectMake(view.center.x, view.center.y, 1000, 150))
        floor.center = CGPointMake(view.center.x, view.center.y*1.8)
        floor.backgroundColor = UIColor.brownColor()
        view.addSubview(floor)
        
        //add a player(ball) to the view
        player = UIView(frame: CGRectMake(view.center.x, floor.frame.origin.y + player.frame.height*2, 30, 30))
        player.center = CGPointMake(view.center.x, floor.frame.origin.y - player.frame.height*2)
        player.backgroundColor = UIColor.grayColor()
        player.layer.cornerRadius = 15
        player.clipsToBounds = true
        view.addSubview(player)
        
        print(defaults.objectForKey("highscore"))
        
        let pushBehavior = UIPushBehavior(items: drops, mode: UIPushBehaviorMode.Instantaneous)
        //direction of push
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
        let floorDynamicBehavior = UIDynamicItemBehavior(items: [floor])
        floorDynamicBehavior.resistance = 1000000
        floorDynamicBehavior.density = 1000000
        dynamicAnimator.addBehavior(floorDynamicBehavior)
        
        let barrelDynamicBehavior = UIDynamicItemBehavior(items: drops)
        barrelDynamicBehavior.density = 10
        barrelDynamicBehavior.resistance = 100
        barrelDynamicBehavior.allowsRotation = false
        
        dynamicAnimator.addBehavior(barrelDynamicBehavior)
        
        
        // add dynamic behavior for the player
        
        let playerDynamicBehavior = UIDynamicItemBehavior(items: [player])
        playerDynamicBehavior.density = 10000
        playerDynamicBehavior.elasticity = 1.0
        playerDynamicBehavior.resistance = CGFloat(resistance)
        
        //add the behaviors to the animators
        dynamicAnimator.addBehavior(playerDynamicBehavior)
        
        
        collisionBehavior = UICollisionBehavior(items: [player, floor] + drops)
        //        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        //        collisionBehavior.collisionMode = .Everything
               collisionBehavior.collisionDelegate = self
        
        dynamicAnimator.addBehavior(collisionBehavior)
        
        
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("changeSpawnPosition"), userInfo: nil, repeats: true)
        
        //spawn frequency
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("spawnObject"), userInfo: nil, repeats: true)
        
        //how much time are we giving the spawn to happen
        NSTimer.scheduledTimerWithTimeInterval(tipTime / 4, target: self, selector: "allowToSpawn", userInfo: nil, repeats: true)
        
        //when can it not spawn
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "speedIncrease", userInfo: nil, repeats: true)
        
        
        var highscoreDefault = NSUserDefaults.standardUserDefaults()
        if highscoreDefault.valueForKey("Highscore") != nil{
            highscore = highscoreDefault.valueForKey("Highscore") as! NSInteger!
            
        }
        
        print(highscore)
    }   
    
    func speedIncrease(){
        objectSpeed++
    }
    func changeSpawnPosition(){
        var randNum = Int(arc4random_uniform(UInt32(self.view.frame.width)))
        self.spawnPoint = CGPointMake(CGFloat(randNum),0)
    }
    
    func cannotSpawn(){
        canSpawn = false
    }
    
    func allowToSpawn(){
        canSpawn = true
    }
    func gethighscore() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    }

    @IBAction func movePlayer(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Up{
            let pushBehaviorUp = UIPushBehavior(items: [player], mode: UIPushBehaviorMode.Instantaneous)
            pushBehaviorUp.pushDirection = CGVectorMake(0, -3.0)
            pushBehaviorUp.magnitude = 0.3
            dynamicAnimator.addBehavior(pushBehaviorUp)
            jumpController++
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "pushDown", userInfo: nil, repeats: false)
            print("Up")
        }
    }
    func spawnObject(){
        if canSpawn2 == true{
        if canSpawn == true {
            let b = Barrel(x: self.spawnPoint.x, y: self.spawnPoint.y, height: 15, width: 15)
            view.addSubview(b.barrel)
            self.gravity.gravityDirection = CGVectorMake(0,CGFloat(objectSpeed))
            drops.append(b.barrel)
            gravity.addItem(b.barrel)
            collisionBehavior.addItem(b.barrel)
            dynamicAnimator.addBehavior(gravity)
            dynamicAnimator.updateItemUsingCurrentState(b.barrel)
            
            }
        }
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        if item1.isEqual(player) || item2.isEqual(player) {
          
            player.removeFromSuperview()
            drops.removeAll()
            floor.removeFromSuperview()
            gameOverLabel.text = "Game Over!"
            yourScore.text = "Score: \(score)"
            highScoreLabel.text = "Best: \(highscore)"
            replayButtonActions.enabled = true
            replayButtonActions.hidden = false
            canSpawn = false
            canSpawn2 = false
        }
        
    }
    
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem) {
        
        if (!item1.isEqual(player) && !item2.isEqual(player)) {
            let theItem:UIView!
            if item1.isEqual(floor) {
                theItem = item2 as! UIView
            } else {
                theItem = item1 as! UIView
            }
          
            theItem.removeFromSuperview()
            collisionBehavior.removeItem(theItem)
            dynamicAnimator.updateItemUsingCurrentState(theItem)
            if canSpawn2 == true {
            score++
            scoreLabel.text = "\(score)"
            }
            if score > highscore {
                highscore = score
                var highscoreDefault = NSUserDefaults.standardUserDefaults()
                highscoreDefault.setValue(highscore, forKey: "Highscore")
                highscoreDefault.synchronize()
            }
        }
    }
    func addScore(){
        scoreLabel.text = "\(score)"
    }
  
    @IBAction func playerPan(sender: UIPanGestureRecognizer) {
        let panGesture = sender.locationInView(view)
        player.center = CGPointMake(panGesture.x, player.center.y)
        dynamicAnimator.updateItemUsingCurrentState(player)
    }
    @IBAction func replayButton(sender: AnyObject) {
        self.performSegueWithIdentifier("previousViewController", sender: nil)
        
    }
    
    
}