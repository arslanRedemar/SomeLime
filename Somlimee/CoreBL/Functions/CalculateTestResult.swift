//
//  CalculateTestResult.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/04.
//

import Foundation

func calculateTestResult(test: PersonalityTestQuestions) -> PersonalityTestResultData{
    
    //internal calculation
    
    var strenuousnessTotal = 0
    var receptivenessTotal = 0
    var harmonizationTotal = 0
    var coagulationTotal = 0
    
    var firstLetter = ""
    var thirdLetter = ""
    
    var i = 0
    while test.answers.count > i{
        let ans = test.answers[i]
        var addScore = 0
        if ans == Answer.Neutral{
            addScore = 2
        }else if ans == Answer.StronglyAgree{
            addScore = 4
        }else if ans == Answer.Agree{
            addScore = 3
        }else if ans == Answer.Disagree{
            addScore = 1
        }else if ans == Answer.StronglyDisagree{
            addScore = 0
        }else{
            addScore = 0
        }
        let cat = test.category[i]
        switch cat{
            case .Air:
                harmonizationTotal += addScore
            case .Fire:
                strenuousnessTotal += addScore
            case .Water:
                receptivenessTotal += addScore
            case .Earth:
                coagulationTotal += addScore
        }
        i += 1
    }
    //Type Calculation
    let resultOfFourCategories = [strenuousnessTotal, receptivenessTotal, harmonizationTotal, coagulationTotal]
    let threshold: Int = (test.questions.count) * 3 / 4 // QNum * NeutralScore / count of categories
    var dominants: [Int] = []
    var index = 0
    let maxScore: Int = resultOfFourCategories.max()!
    let maxIndex = resultOfFourCategories.firstIndex(of: maxScore)!
    for score in resultOfFourCategories{
        if (maxScore - score) < (resultOfFourCategories.reduce(0, +)/10) {
            dominants.append(index)
        }
        index += 1
    }
    switch maxIndex {
    case 0:
        firstLetter = "S"
    case 1:
        firstLetter = "R"
    case 2:
        firstLetter = "H"
    case 3:
        firstLetter = "C"
    default:
        firstLetter = "N"
    }
    if dominants.count < 2{
        var cnt = 0
        for score in resultOfFourCategories {
            if score > threshold {
                cnt += 1
            }
        }
        if cnt >= 3 {
            thirdLetter = "E"
        }else if cnt == 2 {
            thirdLetter = "R"
        }else{
            thirdLetter = "D"
        }
        
    }else{
        //No Decision
        firstLetter = "N"
        var cnt = 0
        for score in resultOfFourCategories {
            if score > threshold {
                cnt += 1
            }
        }
        if cnt >= 3 {
            thirdLetter = "E"
        }else if cnt == 2 {
            thirdLetter = "R"
        }else{
            thirdLetter = "D"
        }
        
    }
    
    return PersonalityTestResultData(Strenuousness: strenuousnessTotal, Receptiveness: receptivenessTotal, Harmonization: harmonizationTotal, Coagulation: coagulationTotal, type: firstLetter + "D" + thirdLetter)
}
