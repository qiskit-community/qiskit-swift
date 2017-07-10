//: Playground - noun: a place where people can play

import Cocoa
import PlaygroundSupport
import XCPlayground
import qiskit

var testurl = "https://quantumexperience.ng.bluemix.net/api/"
var apitoken = "NONE"

do {
    let qconf = try Qconfig(APItoken: apitoken, url: testurl)
    try RippleAdd.rippleAdd(qConfig: qconf)
} catch {
    debugPrint(error.localizedDescription)
}


PlaygroundPage.current.needsIndefiniteExecution = true
