//
//  ViewController.swift
//  Successes
//
//  Created by Jared Lindsay on 2/2/21.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var resultImage: UIImageView!
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var diceStack: UIStackView!
  @IBOutlet weak var defaultDifficultyButton: UIButton!
  
  var lastPressedDifficulty: UIButton? {
    willSet {
      lastPressedDifficulty?.backgroundColor = .systemGray
      newValue?.backgroundColor = .systemBlue
    }
  }
  var lastPressedPool: UIButton? {
    willSet {
      lastPressedPool?.backgroundColor = .systemGray
      newValue?.backgroundColor = .systemRed
    }
  }
  
  var pool: Int?
  var difficulty = 6
  var specialty = false
  var willpower = false
  
  var diceBag: DiceBag? {
    didSet {
      updateDisplay()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    lastPressedDifficulty = defaultDifficultyButton
    resultLabel.text = ""
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
    sender.backgroundColor = specialty ? .systemGreen : .systemGray
  }
  
  @IBAction func toggleWillpower(_ sender: UIButton) {
    willpower.toggle()
    diceBag?.willpower = willpower
    sender.backgroundColor = willpower ? .systemGreen : .systemGray
  }
  
  func updateDisplay() {
    guard let rollResult = diceBag?.result else { return }
    
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
    
    diceStack.removeAllArrangedSubviews()
    for die in diceBag!.dice {
      diceStack.addArrangedSubview(diceView(for: die))
    }
  }
  
  /// Generates a label with a colored background baced on the value of `die`.
  ///
  /// - Parameter die: The content of the label.
  /// - Returns: The formatted label. It has a width constraint of 50.
  func diceView(for die: Int) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    //Set the label apperance
    label.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal,
                                           toItem: nil, attribute: .width, multiplier: 1,
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
        label.backgroundColor = .systemGreen
      } else {
        label.backgroundColor = .lightGreen
      }
    default:
      label.backgroundColor = .lightGray
    }
    
    return label
  }
  
}

