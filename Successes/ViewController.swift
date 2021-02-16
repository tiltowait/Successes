//
//  ViewController.swift
//  Successes
//
//  Created by Jared Lindsay on 2/2/21.
//

import UIKit

class ViewController: UIViewController {
  
  enum RollChange {
    case complete
    case difficulty
    case willpower
    case specialty
    case autos
  }
  
  @IBOutlet weak var resultImage: UIImageView!
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var diceStack: UIStackView!
  @IBOutlet weak var defaultDifficultyButton: UIButton!
  
  var lastPressedDifficulty: UIButton? {
    willSet {
      changeBackground(firstButton: lastPressedDifficulty, firstColor: .systemGray,
                          secondButton: newValue, secondColor: .systemBlue)
    }
  }
  var lastPressedPool: UIButton? {
    willSet {
      changeBackground(firstButton: lastPressedPool, firstColor: .systemGray,
                          secondButton: newValue, secondColor: .systemRed)
    }
  }
  
  var pool: Int?
  var difficulty = 6
  var specialty = false
  var willpower = false
  
  private var _diceBag: DiceBag?
  var diceBag: DiceBag? {
    set {
      let change: RollChange
      
      if newValue?.dice != _diceBag?.dice {
        change = .complete
      } else if newValue?.difficulty != _diceBag?.difficulty {
        change = .difficulty
      } else if newValue?.willpower != _diceBag?.willpower {
        change = .willpower
      } else if newValue?.specialty != _diceBag?.specialty {
        change = .specialty
      } else {
        change = .autos
      }
      _diceBag = newValue
      
      updateDisplay(change: change)
    }
    get {
      _diceBag
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    lastPressedDifficulty = defaultDifficultyButton
    resultLabel.text = ""
    
    // Set all button layer background colors
    for button in self.view.subviews.compactMap({ $0 as? UIButton }) {
      button.layer.backgroundColor = button.backgroundColor?.cgColor
      button.backgroundColor = .clear
    }
  }
  
  @IBAction func poolPressed(_ sender: UIButton) {
    lastPressedPool = sender
    pool = Int(sender.currentTitle!)
    
    diceBag = DiceBag(pool: pool!,
                      specialty: specialty,
                      difficulty: difficulty,
                      willpower: willpower,
                      autos: 0)
  }
  
  @IBAction func difficultyPressed(_ sender: UIButton) {
    lastPressedDifficulty = sender
    difficulty = Int(sender.currentTitle!)!
    diceBag?.difficulty = difficulty
  }
  
  @IBAction func toggleSpecialty(_ sender: UIButton) {
    specialty.toggle()
    diceBag?.specialty = specialty
    changeBackground(firstButton: sender, firstColor: specialty ? .systemGreen : .systemGray)
  }
  
  @IBAction func toggleWillpower(_ sender: UIButton) {
    willpower.toggle()
    diceBag?.willpower = willpower
    changeBackground(firstButton: sender, firstColor: willpower ? .systemGreen : .systemGray)
  }
  
  /// Updates all the displays for the current (or new) roll.
  ///
  /// - Parameter change: Indicates the type of update that needs to occur.
  func updateDisplay(change: RollChange) {
    guard let rollResult = diceBag?.result else { return }
    
    switch rollResult {
    case .failure:
      updateResult(image: #imageLiteral(resourceName: "Failure D10"), label: "0")
    case .botch(let severity):
      updateResult(image: #imageLiteral(resourceName: "Botch D10"), label: "\(severity)")
    case .success(let degree):
      updateResult(image: #imageLiteral(resourceName: "Succes D10"), label: "\(degree)")
    }
    
    let deadline: DispatchTime
    
    switch change {
    case .complete:
      if !diceStack.arrangedSubviews.isEmpty {
        deadline = .now() + 0.1
        
        UIView.animate(withDuration: 0.1, animations: {
          for dieView in self.diceStack.arrangedSubviews {
            dieView.alpha = 0.0
          }
        }) { _ in
          self.diceStack.removeAllArrangedSubviews()
        }
      } else {
        deadline = .now()
      }
      
      DispatchQueue.main.asyncAfter(deadline: deadline) { [self] in
        var delay: TimeInterval = 0.0
        
        for die in diceBag!.dice {
          let dieView = diceView(for: die)
          diceStack.addArrangedSubview(dieView)
          
          // Set a neat little fade in animation
          dieView.alpha = 0.0
          UIView.animate(withDuration: 0.15, delay: delay) {
            dieView.alpha = 1.0
          }
          delay += 0.1
        }
      }
    case .difficulty:
      for dieView in diceStack.arrangedSubviews.map({ $0 as! UILabel }) {
        UIView.animate(withDuration: 0.1) {
          let (dieColor, textColor) = self.background(forDie: dieView.tag)
          dieView.layer.backgroundColor = dieColor
          dieView.textColor = textColor
        }
      }
    case .specialty: // Animate the background change for 10s
      let (dieColor, textColor) = background(forDie: 10)
      
      for dieView in diceStack.arrangedSubviews.map({ $0 as! UILabel }) {
        if dieView.tag == 10 {
          UIView.animate(withDuration: 0.1) {
            dieView.layer.backgroundColor = dieColor
            dieView.textColor = textColor
          }
        }
      }
    default:
      break
    }
  }
  
  /// Generates a label with a colored background baced on the value of `die`.
  ///
  /// - Parameter die: The content of the label.
  /// - Returns: The formatted label. It has a width constraint of 50.
  func diceView(for die: Int) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    label.tag = die
    
    //Set the label apperance
    label.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal,
                                           toItem: nil, attribute: .width, multiplier: 1,
                                           constant: 50))
    label.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal,
                                           toItem: nil, attribute: .height, multiplier: 1,
                                           constant: 50))
    label.layer.cornerRadius = 5
    label.layer.masksToBounds = true
    
    let (dieColor, textColor) = background(forDie: die)
    label.layer.backgroundColor = dieColor
    
    // Set the text and font
    label.text = String(die)
    label.textColor = textColor
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 20, weight: .bold)
    
    return label
  }
  
  /// Returns a `CGColor` based on the `die`.
  ///
  /// - Parameter die: A number from 1-10.
  ///                  1: Red.
  ///                  `Target`+: Light green.
  ///                  10 + specialty: Dark green.
  ///                  All else: Gray.
  /// - Returns: The CGColor for the associated `die`.
  func background(forDie die: Int) -> (CGColor, UIColor) {
    switch die {
    case 1:
      return (UIColor.systemRed.cgColor, .white)
    case difficulty...:
      if die == 10 && specialty {
        return (UIColor.systemGreen.cgColor, .white)
      } else {
        return (UIColor.lightGreen.cgColor, .black)
      }
    default:
      return (UIColor.lightGray.cgColor, .black)
    }
  }
  
  /// Animates the background color change for up to two buttons.
  /// - Parameters:
  ///   - firstButton: The first button to animate
  ///   - firstColor: The new background color for the first button
  ///   - secondButton: The second button to animate
  ///   - secondColor: The new background color for the second button
  func changeBackground(firstButton: UIButton?, firstColor: UIColor?, secondButton: UIButton? = nil, secondColor: UIColor? = nil) {
    UIView.animate(withDuration: 0.15) {
      firstButton?.layer.backgroundColor = firstColor?.cgColor
      secondButton?.layer.backgroundColor = secondColor?.cgColor
    }
  }
  
  /// The transition used for changing the main result background image.
  lazy var transition: CATransition = {
    let transition = CATransition()
    transition.duration = 0.2
    transition.timingFunction = .init(name: .linear)
    transition.type = .fade
    
    return transition
  }()
  
  /// Updates the main result view, animating the image change.
  ///
  /// - Parameters:
  ///   - image: The new background image
  ///   - label: The †ext to overlay the image
  func updateResult(image: UIImage, label text: String) {
    resultImage.image = image
    resultImage.layer.add(transition, forKey: nil) // Animate the transition
    
    resultLabel.text = text
    resultLabel.layer.add(transition, forKey: nil)
  }
  
}

