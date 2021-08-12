//
//  HomeViewController+Extension.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 18/06/2021.
//

import Foundation
import Charts

extension LocationDetailViewController {
    func setupChartView(dataPoints: [String], valuesTemperature: [Double] , valuesHumidity: [Double] ) {
        var dataEntriesBar: [BarChartDataEntry] = []
        var dataEntriesLine: [ChartDataEntry] = []
        let axis: XAxis = XAxis()
        let formatter = XAxisNameFormater()
        formatter.setValues(values: dataPoints)
        
        setupChart()

        for x in 0..<dataPoints.count {
            let dataEntryBar = BarChartDataEntry(x: Double(x), y: valuesTemperature[x])
            let dataEntryLine = ChartDataEntry(x: Double(x), y: valuesHumidity[x])
            dataEntriesBar.append(dataEntryBar)
            dataEntriesLine.append(dataEntryLine)
        }

        let bar = barChartData(forData: dataSetBarChart(dataEntry: dataEntriesBar))
        let line =  lineChartData(forData: dataSetLineChart(dataEntry: dataEntriesLine))
        setupIAxis(for: axis, for: formatter)
        setupYAxis()
        setupRightAxis()
        
        chartView.data = combinedData(dataLine: line, dataBar: bar)
    }
    
    func setupChart() {
        chartView.delegate = self
        chartView.legend.enabled = false
        chartView.pinchZoomEnabled = false
        chartView.highlightFullBarEnabled = false
    }
    
    func dataSetBarChart(dataEntry data: [ChartDataEntry]?) -> ChartDataSet {
        let chartDataSetBar = BarChartDataSet(entries: data)
        chartDataSetBar.colors = [NSUIColor(cgColor: Colors.selectedPageAndGraphics!.cgColor)]
        chartDataSetBar.axisDependency = .right
        return chartDataSetBar
    }
    
    func dataSetLineChart(dataEntry data: [ChartDataEntry]?) -> [IChartDataSet] {
        let chartDataSetLine = LineChartDataSet(entries: data)
        chartDataSetLine.colors = [NSUIColor(cgColor: Colors.chartTextAndLine!.cgColor)]
        chartDataSetLine.drawCirclesEnabled = false
        chartDataSetLine.mode = .cubicBezier
        chartDataSetLine.lineWidth = 2
        chartDataSetLine.lineDashPhase = 0
        chartDataSetLine.drawValuesEnabled = true
        chartDataSetLine.lineDashLengths = [2,5]
        chartDataSetLine.axisDependency = .left
        return [chartDataSetLine]
    }
    
    func barChartData(forData data: IChartDataSet) -> BarChartData {
        let barChartData = BarChartData(dataSet: data)
        barChartData.barWidth = 0.6
        barChartData.setDrawValues(false)
        return barChartData
    }
    
    func lineChartData(forData data: [IChartDataSet]) -> LineChartData {
        let lineChartData = LineChartData(dataSets: data)
        lineChartData.setDrawValues(false)
        return lineChartData
    }
    
    func combinedData(dataLine line: LineChartData, dataBar bar: BarChartData) -> CombinedChartData {
        let comData = CombinedChartData()
        comData.barData = bar
        comData.lineData = line
        return comData
    }
    
    func setupIAxis(for axis: XAxis, for formatter: IAxisValueFormatter) {
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
        xAxis.labelTextColor = Colors.chartTextAndLine!
        xAxis.labelFont = Fonts.RoundedBold
    }
    
    func setupRightAxis() {
        let rightAxis = chartView.rightAxis
        rightAxis.valueFormatter = RightAxisFormatter()
        rightAxis.drawGridLinesEnabled = false
        rightAxis.axisLineWidth = 0
        rightAxis.granularity = 15
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 55
        rightAxis.labelTextColor = Colors.selectedPageAndGraphics!
        rightAxis.labelFont = Fonts.RoundedBold
    }
    
    func setupYAxis() {
        let yAxis = chartView.leftAxis
        yAxis.valueFormatter = YAxisFormatter()
        yAxis.drawGridLinesEnabled = false
        yAxis.axisLineWidth = 0
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 100
        yAxis.granularity = 30
        yAxis.labelTextColor = Colors.chartTextAndLine!
        yAxis.labelFont = Fonts.RoundedBold
    }
    
}


