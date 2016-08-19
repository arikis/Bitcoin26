//
//  ChartView.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Charts
import CoinDesk

class ChartView: UIView {
    
    /// Main bar chart view instance
    let barChartView: LineChartView = {
        let chart = LineChartView()
        chart.legend.enabled = false
        chart.descriptionText = ""
        
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = false
        
        chart.leftAxis.drawZeroLineEnabled = true
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawLabelsEnabled = true
        chart.leftAxis.labelPosition = ChartYAxis.LabelPosition.InsideChart
        chart.leftAxis.labelTextColor = UIColor(red:0.21, green:0.29, blue:0.36, alpha:1.00)
        chart.leftAxis.drawAxisLineEnabled = false
        
        chart.rightAxis.drawAxisLineEnabled = false
        chart.rightAxis.drawLabelsEnabled = false
        
        chart.extraLeftOffset = 0
        chart.minOffset = 0
        chart.pinchZoomEnabled = false
        chart.setScaleEnabled(false)
        chart.dragDecelerationEnabled = false
        
        chart.noDataText = "No chart data available, please connect to the Internet."
        chart.infoTextColor = UIColor(red:0.21, green:0.29, blue:0.36, alpha:1.00)
        
        chart.animate(yAxisDuration: 1)
        
        chart.marker = RateMarker(
            color: UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00),
            font: UIFont.systemFontOfSize(16),
            insets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 20.0, right: 8)
        )
        
        return chart
    }()
    
    /// Timestamp view shown at the bottom of the chart
    let timestampView = TimestampView()
    
    /// Scheduled rate entry
    var scheduledRateEntry: ExchangeRate?
    
    //MARK: Auto layout
    
    func prepareViews() {
        addSubview(barChartView)
        barChartView.addSubview(timestampView)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        timestampView.translatesAutoresizingMaskIntoConstraints = false
        
        var chartConstraints = [NSLayoutConstraint]()
        
        chartConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[chart]|",
                options: [],
                metrics: nil,
                views: ["chart": barChartView]
            )
        )
        
        chartConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[chart]|",
                options: [],
                metrics: nil,
                views: ["chart": barChartView]
            )
        )
        
        NSLayoutConstraint.activateConstraints(chartConstraints)
        
        var timestampViewConstraints = [NSLayoutConstraint]()
        
        timestampViewConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[legend]-|",
                options: [],
                metrics: nil,
                views: ["legend": timestampView]
            )
        )
        
        timestampViewConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[legend]|",
                options: [],
                metrics: nil,
                views: ["legend": timestampView]
            )
        )
        
        NSLayoutConstraint.activateConstraints(timestampViewConstraints)
    }
    
    //MARK: Data updates
    
    /// Updates chart with rates
    func updateChart(rates: [ExchangeRate]) {
        // If there are zero exchange rates, return from the function
        if rates.count == 0 { return }
        
        // Create and setup data set for the chart
        var xValues = [Int](0..<rates.count)
        var dataEntries = rates.enumerate().map { ChartDataEntry(value: $1.euroValue, xIndex: $0) }
        
        // Check if there's a scheduled entry
        // If there is, add it to the data entries
        if let scheduledRateEntry = scheduledRateEntry {
            
            if dataEntries.count < 28 {
                xValues.append(xValues.last! + 1)
            }
            
            let entry = ChartDataEntry(value: scheduledRateEntry.euroValue, xIndex: xValues.count - 1)
            dataEntries.append(entry)
        }
        
        // Create chart data set
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "Rates")
        
        chartDataSet.mode = .CubicBezier
        chartDataSet.circleRadius = 0
        
        chartDataSet.colors = [UIColor(red:0.42, green:0.80, blue:0.80, alpha:1.00)]
        chartDataSet.fillAlpha = 1
        
        let gradientColors = [
            UIColor(red: 0.70, green: 0.90, blue: 0.89, alpha: 1).CGColor,
            UIColor(red: 0.42, green: 0.80, blue: 0.80, alpha: 1).CGColor
        ]
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        if let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradientColors, colorLocations) {
            chartDataSet.fill = ChartFill(linearGradient: gradient, angle: 90.0)
        }
        
        chartDataSet.drawValuesEnabled = false
        chartDataSet.drawFilledEnabled = true
        
        chartDataSet.drawVerticalHighlightIndicatorEnabled = true
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        chartDataSet.highlightColor = UIColor(red:0.21, green:0.29, blue:0.36, alpha:1.00)
        
        let chartData = LineChartData(xVals: xValues, dataSet: chartDataSet)
        
        // Set chart data to update chart view
        self.barChartView.data = chartData
    }
    
    func scheduleLatestRate(rate: ExchangeRate) {
        
        /// All entries in graph
        let entryCount = barChartView.lineData?.dataSets[0].entryCount
        
        // Check if there's entry count
        if let entryCount = entryCount {
            
            // If there are less than 28 entries we need to add new
            if entryCount < 28 {
                let entry = ChartDataEntry(value: rate.euroValue, xIndex: entryCount - 1)
                barChartView.lineData?.dataSets[0].addEntryOrdered(entry)
                barChartView.lineData?.notifyDataChanged()
            } else {
                
                // If there are 28 entries we need to update last entry
                barChartView.lineData?.dataSets[0].removeLast()
                let entry = ChartDataEntry(value: rate.euroValue, xIndex: 27)
                barChartView.lineData?.dataSets[0].addEntryOrdered(entry)
            }
            
            barChartView.lineData?.dataSets[0].notifyDataSetChanged()
        } else {
            
            // No entries in the chart yet, just schedule it
            scheduledRateEntry = rate
        }
    }
    
    //MARK: Init methods
    init() {
        super.init(frame: CGRect.zero)
        prepareViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Reactive extensions

extension ChartView {
    
    var rx_historicalRates: AnyObserver<[ExchangeRate]> {
        return UIBindingObserver(UIElement: self) { (view: ChartView, rates: [ExchangeRate]) in
            view.updateChart(rates)
            }.asObserver()
    }
    
    var rx_current: AnyObserver<ExchangeRate> {
        return UIBindingObserver(UIElement: self) { (view: ChartView, rate: ExchangeRate) in
            view.scheduleLatestRate(rate)
            }.asObserver()
    }
}
