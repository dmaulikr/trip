//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var date = "11/12/16"
date = date.stringByReplacingOccurrencesOfString("/", withString: "-")
let components = date.componentsSeparatedByString("-")
print(components)
