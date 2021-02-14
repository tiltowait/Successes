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
      animateButtonChange(firstButton: lastPressedDifficulty, firstColor: .systemGray,
                          secondButton: newValue, secondColor: .systemBlue)
    }
  }
  var lastPressedPool: UIButton? {
    willSet {
      animateButtonChange(firstButton: lastPressedPool, firstColor: .systemGray,
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
    animateButtonChange(firstButton: sender, firstColor: specialty ? .systemGreen : .systemGray)
  }
  
  @IBAction func toggleWillpower(_ sender: UIButton) {
    willpower.toggle()
    diceBag?.willpower = willpower
    animateButtonChange(firstButton: sender, firstColor: willpower ? .systemGreen : .systemGray)
  }
  
  func updateDisplay(change: RollChange) {
    guard let rollResult = diceBag?.result else { return }
    print(rollResult)
    switch rollResult {
    case .failure:
      resultImage.image = #imageLiteral(resourceName: "Failure D10")
      resultLabel.text = ""
      resultLabel.textColor = .black
    case .botch(let severity):
      resultImage.image = #imageLiteral(resourceName: "Botch D10")
      resultLabel.text = "\(severity)"
      resultLabel.textColor = .white
    case .success(let degree):
      resultImage.image = #imageLiteral(resourceName: "Succes D10")
      resultLabel.text = "\(degree)"
      resultLabel.textColor = .white
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
    case .specialty:
      // Animate the background change for 10s
      for dieView in diceStack.arrangedSubviews {
        if dieView.tag == 10 {
          UIView.animate(withDuration: 0.1) {
            dieView.layer.backgroundColor = self.specialty ? UIColor.systemGreen.cgColor : UIColor.lightGreen.cgColor
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
    
    // Set the text and font
    label.text = String(die)
    label.textColor = .white
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 20, weight: .bold)
    
    // Set label background color
    switch die {
    case 1:
      label.backgroundColor = .red
    case difficulty...:
      if die == 10 && specialty {
        label.layer.backgroundColor = UIColor.systemGreen.cgColor
      } else {
        label.layer.backgroundColor = UIColor.lightGreen.cgColor
      }
    default:
      label.backgroundColor = .lightGray
    }
    
    return label
  }
  
  /// Animates the background color change for up to two buttons.
  /// - Parameters:
  ///   - firstButton: The first button to animate
  ///   - firstColor: The new background color for the first button
  ///   - secondButton: The second button to animate
  ///   - secondColor: The new background color for the second button
  func animateButtonChange(firstButton: UIButton?, firstColor: UIColor?, secondButton: UIButton? = nil, secondColor: UIColor? = nil) {
    UIView.animate(withDuration: 0.1) {
      firstButton?.layer.backgroundColor = firstColor?.cgColor
      secondButton?.layer.backgroundColor = secondColor?.cgColor
    }
  }
  
}

