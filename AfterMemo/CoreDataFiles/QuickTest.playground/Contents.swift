import UIKit

var str = "Hello, playground"

var myArray = [1]

myArray.reserveCapacity(10000000)

for i in 0...1000 {
    myArray.append(i)
    
}