//
//  ViewController.swift
//  MatchEmScene
//
//  Created by Guest User on 9/21/22.
//

import UIKit

// Min and max width and height for the rectangles
private let rectSizeMin:CGFloat =  50.0
private let rectSizeMax:CGFloat = 150.0
// Random transparency on or off
private var randomAlpha = false
// How long for the rectangle to fade away
private var fadeDuration: TimeInterval = 0.8
var dictionary: [UIButton: UIButton] = [:]
// Keep track of all rectangles created
private var rectangles = [UIButton]()
private var firstTouched:UIButton?
private var flag = true
// Rectangle creation interval
private var newRectInterval: TimeInterval = 1.0
// Rectangle creation, so the timer can be stopped
private var newRectTimer: Timer?
// Counters
private var rectanglesCreated = 0
private var rectanglesTouched = 0
// Game duration
private var gameDuration: TimeInterval = 12.0
//game time
private var gameTimer: Timer?
// A game is in progress
private var gameInProgress = false

class GameSceneViewController: UIViewController {
    
    private let startButton: UIButton = {
        let startButton = UIButton()
        startButton.backgroundColor = .black
        startButton.setTitle("START", for: .normal)
        startButton.setTitleColor(.green, for: .normal)
        return startButton
    }()


    
    
    @IBOutlet weak var gameInfoLabel: UILabel!
   
    
    private var gameInfo: String {
        
        let labelText = String(format: "Time: %2.1f Created: %2d Touch: %2d",
                               gameTimeRemaining, rectanglesCreated, rectanglesTouched)
        // End of game, no time left, make sure label is updated
//        gameTimeRemaining = 0.0
//        gameInfoLabel?.text = gameInfo
        return labelText
    }
    
    // Counters, property observers used
    private var rectanglesCreated: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }
    private var rectanglesTouched: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }
    // Init the time remaining
    private var gameTimeRemaining = gameDuration {
        didSet { gameInfoLabel?.text = gameInfo }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(startButton)
        startButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.frame = CGRect(x:30,
                                   y: view.frame.size.height-500-view.safeAreaInsets.bottom,
                                   width: view.frame.size.width - 60,
                                   height:60)
    }
    
    

//    //================================================
//    override func viewWillAppear(_ animated: Bool) {
//        // Don't forget the call to super in these methods
//        super.viewWillAppear(animated)
//
//    startGameRunning()
//    }
    
    
    //================================================
    @objc private func handleTouch(sender: UIButton) {
        sender.setTitle("👾", for: .normal)
        //Return from handleTouch if there is no game in progress.
        
        if flag{
            firstTouched = sender
            flag = false
            return
        }else{
            if dictionary[sender] == firstTouched{
                dictionary.removeValue(forKey: sender)
                dictionary.removeValue(forKey: firstTouched!)
                removeRectangle(rectangle: sender)
                sender.removeFromSuperview()
                firstTouched!.removeFromSuperview()
                rectanglesTouched = rectanglesTouched + 1
         
            }else{
                sender.setTitle("", for: .normal)
                firstTouched!.setTitle("", for: .normal)
            }
            
            flag = true
        }
    }
        
    
}
extension GameSceneViewController{
        private func createRectangle() {
            // Decrement the game time remaining
            gameTimeRemaining -= newRectInterval
            rectanglesCreated = rectanglesCreated + 1
            // Get random values for size and location
            let randSize     = Utility.getRandomSize(fromMin: rectSizeMin, throughMax: rectSizeMax)
            let randLocation = Utility.getRandomLocation(size: randSize, screenSize: view.bounds.size)//change to safe view
            let randLocation2 = Utility.getRandomLocation(size: randSize, screenSize: view.bounds.size)//change to safe view
            let randomFrame  = CGRect(origin: randLocation, size: randSize)
            let randomFrame2  = CGRect(origin: randLocation2, size: randSize)
            let randomColor = Utility.getRandomColor(randomAlpha: randomAlpha)
            
            // Creating rectangle 1
            //let rectangleFrame = CGRect(x: 50, y: 150, width: 80, height: 40)
            let rectangle = UIButton(frame: randomFrame)
            // Save the rectangle till the game is over
            rectangles.append(rectangle)
            // Do some button/rectangle setup
            rectangle.backgroundColor = randomColor
            rectangle.setTitle("", for: .normal)
            rectangle.setTitleColor(.black, for: .normal)
            rectangle.titleLabel?.font = .systemFont(ofSize: 50)
            rectangle.showsTouchWhenHighlighted = true
            // Target/action to set up connect of button to the VC
            rectangle.addTarget(self,
                             action: #selector(self.handleTouch(sender:)),
                             for: .touchUpInside)

            // Creating rectangle 2
            //let rectangleFrame2 = CGRect(x: 30, y: 130, width: 80, height: 40)
            let rectangle2 = UIButton(frame: randomFrame2)
            // Save the rectangle till the game is over
            rectangles.append(rectangle2)
            // Do some button/rectangle setup
            rectangle2.backgroundColor = randomColor
            rectangle2.setTitle("", for: .normal)
            rectangle2.setTitleColor(.black, for: .normal)
            rectangle2.titleLabel?.font = .systemFont(ofSize: 50)
            rectangle2.showsTouchWhenHighlighted = true
            // Target/action to set up connect of button to the VC
            rectangle2.addTarget(self,
                             action: #selector(self.handleTouch(sender:)),
                             for: .touchUpInside)
            
            //dictionary
            dictionary[rectangle] = rectangle2
            dictionary[rectangle2] = rectangle
    
            
                self.view.addSubview(rectangle)
                self.view.addSubview(rectangle2)
            // Move label to the front
            view.bringSubviewToFront(gameInfoLabel!)
            view.bringSubviewToFront(startButton)
        }
    
    //================================================
    func removeRectangle(rectangle: UIButton) {
        // Rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: fadeDuration,
                                           curve: .linear,
                                      animations: nil)
        pa.addAnimations {
            rectangle.alpha = 0.0
        }
        pa.startAnimation()
    }
    

}
extension GameSceneViewController {
    //================================================
    func removeSavedRectangles() {
        // Remove all rectangles from superview
        for rectangle in rectangles {
            rectangle.removeFromSuperview()
        }
        
        // Clear the rectangles array
        rectangles.removeAll()
    }
    //================================================
    private func startGameRunning()
    {
        // A game is in progress
        gameInProgress = true
        rectanglesCreated = 0
        rectanglesTouched = 0
        // Timer to produce the rectangles
        newRectTimer = Timer.scheduledTimer(withTimeInterval: newRectInterval,
                                     repeats: true)
                                     { _ in self.createRectangle() }
        
        
        // Timer to end the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameDuration,
                                                  repeats: false)
                                   { _ in self.stopGameRunning() }
        // Init label colors
        gameInfoLabel.textColor = .black
        gameInfoLabel.backgroundColor = .clear
        
    }
    //================================================
    private func stopGameRunning() {
        
        // A game is stopped
        gameInProgress = false
        
        // Stop the timer
        if let timer = newRectTimer { timer.invalidate() }
        // Remove the reference to the timer object
        //self.newRectTimer = 0
        // Make the label stand out
        gameInfoLabel.textColor = .red
        gameInfoLabel.backgroundColor = .black
        startButton.alpha = 1
    }
    
    @objc func didTapButton (){
        
        UIView.animate(withDuration: 1, animations: {
            self.startGameRunning()
        })
        gameInfoLabel.alpha = 1
        startButton.alpha = 0.0
    }
    //================================================
    override var prefersStatusBarHidden: Bool {
               return true
    }
}



