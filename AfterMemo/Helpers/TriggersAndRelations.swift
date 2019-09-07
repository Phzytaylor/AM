//
//  Triggers.swift
//  AfterMemo
//
//  Created by Taylor Simpson on 7/27/18.
//  Copyright © 2018 Taylor Simpson. All rights reserved.
//

import Foundation
import UIKit

struct Triggers {
    public var triggerArray:[String] = ["Marriage","First Child","Second Child","Additional Children","First Home","First Career Job","Midlife Encourgement","Graduating from HighSchool","Graduating from College","Buying a Car","Loss of a loved One",
        "Becoming a grand parent","5 Year Wedding Anniversary","10 Year Wedding Anniversary","20 Year Wedding Anniversary","7 Year Marriage Slump","Changing Careers", "21st Birthday", "30th Birthday", "40th Birthday", "50th Birthday","60th Birthday", "70th Birthday","Pass Driving Test", "None", "Birthday"]
}

enum MileStones: String {
    case Marriage = "Marriage"
    case FirstChild = "First Child"
    case SecondChild = "Second Child"
    case AdditionalChildren = "Additional Children"
    case FirstHome = "First Home"
    case FirstCareerJob = "First Career Job"
    case MidlifeEncourgement = "Midlife Encourgement"
    case GraduatingHighSchool = "Graduating from HighSchool"
    case GraduatingCollege = "Graduating from College"
    case BuyingACar = "Buying a Car"
    case LossOfLovedOne = "Loss of a loved One"
    case BecomeGrandParent = "Becoming a grand parent"
    case FiveYearWeddingAni = "5 Year Wedding Anniversary"
    case TenYearWeddingAni = "10 Year Wedding Anniversary"
    case TwentyYearWeddingAni = "20 Year Wedding Anniversary"
    case SevenYearSlump = "7 Year Marriage Slump"
    case CareerChange = "Changing Careers"
    case TwentyFirstBday = "21st Birthday"
    case ThirtyBday = "30th Birthday"
    case FourtyBday = "40th Birthday"
    case FiftyBday = "50th Birthday"
    case SixtyBday = "60th Birthday"
    case SeventyBday = "70th Birthday"
    case PassDrivingTest = "Pass Driving Test"
    case Birthday = "Birthday"
    case None = "None"
    
}

struct Relations {
    public var relationArray:[String] = ["Mother","Father","Sister","Brother", "Son", "Daughter", "Granddaughter", "Grandson", "Great Granddaughter", "Great Grandson", "Uncle","Aunt", "Nephew","Niece","Wife", "Husband","Parent","Cousin", "Friend" ,"Best Friend", "Mother In Law", "Father In Law", "Daughter In Law", "Son In Law", "Step Son", "Step Daughter", "Step Mom", "Step Dad", "Half Sister", "Half Brother", "Self", "Nanny", "Dog Walker", "Baby Sitter", "Neighbor", "Pastor", "Priest", "Driver", "Butler", "Coworker"]
}

enum RelationEnum: String {
case Wife = "Wife"
case Husband = "Husband"
}
