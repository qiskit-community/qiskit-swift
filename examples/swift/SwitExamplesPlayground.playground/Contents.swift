//: Playground - noun: a place where people can play

import Cocoa
import PlaygroundSupport
import XCPlayground
import qiskit

var testurl = "https://quantumexperience.ng.bluemix.net/api/"
var apitoken = "NONE"

func runDataMove() {
    do {
        let qconf = try Qconfig(APItoken: apitoken, url: testurl)
        try DataMove.dataMove(qConfig: qconf)
    } catch {
        debugPrint(error.localizedDescription)
    }
}

func runGHZ() {
    do {
        let qconf = try Qconfig(APItoken: apitoken, url: testurl)
        try GHZ.ghz(qConfig: qconf)
    } catch {
        debugPrint(error.localizedDescription)
    }
}

func runMultiple() {
    do {
        let qconf = try Qconfig(APItoken: apitoken, url: testurl)
        try Multiple.multiple(qConfig: qconf)
    } catch {
        debugPrint(error.localizedDescription)
    }
}


func runRippleExample() {
    do {
        let qconf = try Qconfig(APItoken: apitoken, url: testurl)
        try RippleAdd.rippleAdd(qConfig: qconf)
    } catch {
        debugPrint(error.localizedDescription)
    }
}

func runQFT() {
    do {
        let qconf = try Qconfig(APItoken: apitoken, url: testurl)
        try QFT.qft(qConfig: qconf)
    } catch {
        debugPrint(error.localizedDescription)
    }
}


//TODO run your example here
PlaygroundPage.current.needsIndefiniteExecution = true
