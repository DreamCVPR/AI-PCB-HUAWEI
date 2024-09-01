var myChart = echarts.init(document.getElementById('columnChart'),);

var option = {
    title: {
        text: '数量',
        left: 5,
    },

    legend: {
        data:['数量'],
        textStyle: {
            fontSize: 24,
        },
    },
    xAxis: {
        data: ['咬伤', '开路', '短路', '支线', '杂铜']
    },
    yAxis: {},
    series: [
        {
            name: '数量',
            type: 'bar',
            stack: 'x',
            data: [5, 20, 36, 10, 10,],
            itemStyle: {
                color: {
                    x: 0,
                    y: 1,
                    x2: 0,
                    y2: 0,
                    colorStops:
                        [
                            { offset: 0, color: 'rgba(26, 132, 191, 1)' },
                            { offset: 1, color: 'rgba(52, 163, 224, 0.08)' },
                        ],

                    global: false // 缺省为 false
                }
            }
        },
    ]
};

// 使用刚指定的配置项和数据显示图表。
myChart.setOption(option);
