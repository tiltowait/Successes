//
//  ViewController.swift
//  Successes
//
//  Created by Jared Lindsay on 2/2/21.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var rawResultLabel: UILabel!
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
  }
  
  @IBAction func poolPressed(_ sender: UIButton) {
    lastPressedPool = sender
    pool = Int(sender.title(for: .normal)!)
    
    diceBag = DiceBag(pool: pool!,
                      specialty: specialty,
                      difficulty: difficulty,
                      willpower: willpower,
                      autos: 0)
  }
  
  @IBAction func difficultyPressed(_ sender: UIButton) {
    lastPressedDifficulty = sender
    difficulty = Int(sender.title(for: .normal)!)!
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
      resultLabel.text = "Failure"
    case .botch(let severity):
      resultLabel.text = "\(severity) Botch"
    case .success(let degree):
      resultLabel.text = "\(degree) \(degree > 1 ? "Successes" : "Success")"
    }
  }
  
}

