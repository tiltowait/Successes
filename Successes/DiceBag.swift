//
//  DiceBag.swift
//  Successes
//
//  Created by Jared Lindsay on 2/13/21.
//

import Foundation

struct DiceBag {
  enum Result {
    case botch(Int)
    case failure
    case success(Int)
  }
  
  let dice: [Int]
  var specialty: Bool
  var difficulty: Int
  var willpower: Bool
  var autos: Int
  
  init(pool: Int, specialty: Bool, difficulty: Int, willpower: Bool, autos: Int) {
    dice = (1...pool).map { _ in Int.random(in: 1...10) }
    self.specialty = specialty
    self.difficulty = difficulty
    self.willpower = willpower
    self.autos = autos
  }
  
  var result: Result {
    var successes = dice.filter { $0 >= difficulty }.count + autos
    let ones = dice.filter { $0 == 1 }.count
    
    if specialty {
      successes += dice.filter { $0 == 10 }.count
    }
    
    var net = successes - ones
    if willpower {
      net = net < 0 ? 1 : net + 1
    }
    switch net {
    case ..<0:
      if successes == 0 {
        return .botch(ones)
      }
      return .failure
    case 0:
      return .failure
    default:
      return .success(net)
    }
  }
}
