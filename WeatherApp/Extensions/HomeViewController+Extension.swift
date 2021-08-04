//
//  HomeViewController+Extension.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 18/06/2021.
//

import Foundation
import Charts

extension HomeViewController {
    
    func setupChartView(dataPoints: [String], valuesTemperature: [Double] , valuesHumidity: [Double] ) {
        
        chartView.delegate = self
        chartView.legend.enabled = false
        chartView.pinchZoomEnabled = false
        chartView.highlightFullBarEnabled = false
        
        //Formatter for change values in xAxis
        let formatter = XAxisNameFormater()
        formatter.setValues(values: dataPoints)
        let axis:XAxis = XAxis()
        
        // Supply data
        var dataEntriesBar: [BarChartDataEntry] = []
        var dataEntriesLine: [ChartDataEntry] = []
        for x in 0..<dataPoints.count {
            let dataEntryBar = BarChartDataEntry(x: Double(x), y: valuesTemperature[x])
            let dataEntryLine = ChartDataEntry(x: Double(x), y: valuesHumidity[x])
            dataEntriesBar.append(dataEntryBar)
            dataEntriesLine.append(dataEntryLine)
        }
        
        let chartDataSetBar = BarChartDataSet(entries: dataEntriesBar)
        chartDataSetBar.colors = [NSUIColor(cgColor: UIColor(named: "SelectedPage+Grafics")!.cgColor)]
        chartDataSetBar.axisDependency = .right
        
        let chartDataSetLine = LineChartDataSet(entries: dataEntriesLine)
        chartDataSetLine.colors = [NSUIColor(cgColor: UIColor(named: "ChartText+Line")!.cgColor)]
        chartDataSetLine.drawCirclesEnabled = false
        chartDataSetLine.mode = .cubicBezier
        chartDataSetLine.lineWidth = 2
        chartDataSetLine.lineDashPhase = 0
        chartDataSetLine.drawValuesEnabled = true
        chartDataSetLine.lineDashLengths = [2,5]
        chartDataSetLine.axisDependency = .left
        
        let barChartData = BarChartData(dataSets: [chartDataSetBar])
        barChartData.barWidth = 0.6
        barChartData.setDrawValues(false)

        let lineChartData = LineChartData(dataSets: [chartDataSetLine])
        lineChartData.setDrawValues(false)
        
        let comData = CombinedChartData()
        comData.barData = barChartData
        comData.lineData = lineChartData
        
        //Setup UI Chart
        let xAxis = chartView.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.avoidFirstLastClippingEnabled = false
        xAxis.axisLineWidth = 0
        xAxis.granularity = 1
        xAxis.spaceMax = 0.32
        xAxis.spaceMin = 0.32
        xAxis.labelPosition = .bottom
        axis.valueFormatter = formatter
        xAxis.valueFormatter = axis.valueFormatter
        xAxis.labelTextColor = UIColor(named: "ChartText+Line")!
        xAxis.labelFont = UIFont(name: "SFProRounded-Bold", size: 12)!
        
        let rightAxis = chartView.rightAxis
        rightAxis.valueFormatter = RightAxisFormatter()
        rightAxis.drawGridLinesEnabled = false
        rightAxis.axisLineWidth = 0
        rightAxis.granularity = 15
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 55
        rightAxis.labelTextColor = UIColor(named: "SelectedPage+Grafics")!
        rightAxis.labelFont = UIFont(name: "SFProRounded-Bold", size: 12)!
        
        let yAxis = chartView.leftAxis
        yAxis.valueFormatter = YAxisFormatter()
        yAxis.drawGridLinesEnabled = false
        yAxis.axisLineWidth = 0
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 100
        yAxis.granularity = 30
        
        yAxis.labelTextColor = UIColor(named: "ChartText+Line")!
        yAxis.labelFont = UIFont(name: "SFProRounded-Bold", size: 12)!
        
        chartView.data = comData
        
    }
    
}
