export function getChartData (parameter) {
    return requests({
        url: 'chartData',
        method: 'post',
        data: parameter
    })
}