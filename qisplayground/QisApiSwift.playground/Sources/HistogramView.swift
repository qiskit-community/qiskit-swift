//
//  HistogramView.swift
//  QIKitAnalysis
//
//  Created by Joe Ligman on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa
import CorePlot

public class HistogramView: CPTGraphHostingView {
    
    
    fileprivate struct BarPlotStruct {
        var xpos: CGFloat
        var ypos: CGFloat
        var title: String
        var barplot: CPTBarPlot
    }
    
    fileprivate var barWidth:NSNumber = 1
    fileprivate var bars:[BarPlotStruct] = []
    
    fileprivate func randomColor() -> NSColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 
        return NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    public func showResultsByExecution(results: [String:AnyObject]) {

        bars.removeAll()
        
        guard let labels = results["labels"] as? [AnyObject] else { return }
        guard let values = results["values"] as? [AnyObject] else { return }
        
        if values.count != labels.count { return }
        
        for index in 0..<values.count {
            let label = "\(labels[index])"
            let value = values[index] as! NSNumber
            
            let bar = CPTBarPlot()
            bar.title = label
            bar.fill = CPTFill(color: CPTColor(cgColor: randomColor().cgColor))
            bars.append(BarPlotStruct(xpos: CGFloat(index), ypos: CGFloat(value.floatValue), title: label, barplot: bar))
        }
        configureGraph()
        configureChart()
        configureAxes()
    }
    
    func showResultsByExecution() {
        bars.removeAll()
        configureGraph()
        configureChart()
        configureAxes()
    }
}


extension HistogramView: CPTBarPlotDelegate, CPTBarPlotDataSource {
    
    
    fileprivate func configureGraph() {
        let graph = CPTXYGraph(frame: bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostedGraph = graph
        
        graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 30.0
        graph.paddingLeft = 60.0
        graph.paddingTop = 30.0
        graph.paddingRight = 30.0
        
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle
        
        let title = "Quantum State: Computation Basis"
        
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        
        // 4 - Set up plot space
        let xMin = Double(0)
        let xMax = Double(6)
        let yMin = Double(0)
        let yMax = Double(1.2)
        
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
        
    }
    
    fileprivate func configureChart() {
        guard let graph = hostedGraph else { return }
        
        var barX:Float = 2
        for barstruct in bars {
            barstruct.barplot.dataSource = self
            barstruct.barplot.barWidth = barWidth
            barstruct.barplot.barOffset = NSNumber(value: barX)
            graph.add(barstruct.barplot, to: graph.defaultPlotSpace)
            barX += 2
        }
    }
    
    
    fileprivate func configureAxes() {
        
        // 1 - Configure styles
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.black()
        
        // 2 - Get the graph's axis set
        guard let axisSet = hostedGraph?.axisSet as? CPTXYAxisSet else { return }
        
        // 3 - Configure the x-axis
        if let xAxis = axisSet.xAxis {
            xAxis.labelingPolicy = .none
            xAxis.majorIntervalLength = 0.5
            xAxis.axisLineStyle = axisLineStyle
            var majorTickLocations = Set<NSNumber>()
            var axisLabels = Set<CPTAxisLabel>()
            
            var barX:Float = 2
            for idx in 0..<bars.count {
                majorTickLocations.insert(NSNumber(value: idx))
                let label = CPTAxisLabel(text: "\(bars[idx].title)", textStyle: CPTTextStyle())
                label.tickLocation = NSNumber(value: barX)
                label.offset = 0.0
                label.alignment = .left
                axisLabels.insert(label)
                barX += 2
            }
            
            xAxis.majorTickLocations = majorTickLocations
            xAxis.axisLabels = axisLabels
        }
        
        // 4 - Configure the y-axis
        if let yAxis = axisSet.yAxis {
            yAxis.labelingPolicy = .automatic
        }
        
    }
    
    // MARK - CPTBarPlotDelegate, CPTBarPlotDataSource
    fileprivate func normal_pdf(x: Double, m: Double, s: Double) -> Double {
        let inv_sqrt_2pi: Double = 0.3989422804014327
        let a = (x - m) / s
        return inv_sqrt_2pi / s * exp(-0.5 * a * a)
    }
    
    public func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 1
    }
    
    public func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        if plot is CPTBarPlot {
            if fieldEnum == UInt(CPTBarPlotField.barTip.rawValue) {
                let bf =  bars.filter{
                    return $0.barplot == plot
                }
                
                let ypos = bf.first?.ypos
                return ypos as AnyObject
            }
        }
        return idx
    }
}
