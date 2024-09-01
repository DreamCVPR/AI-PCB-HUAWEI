// 柱状图

var myChartBar = echarts.init(document.getElementById('chartBar'),);

var optionBar = {
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
        data: ['咬伤', '开路', '短路', '支线', '杂铜'],
        axisLabel: {
            fontSize: 24, // 这里设置x轴标签字体大小
            rotate: 0,  // 如果标签较长，可以选择旋转
            interval: 0, // 显示所有标签
        }
    },
    yAxis: {
        axisLabel: {
            fontSize: 24,
        }
    },
    series: [
        {
            name: '数量',
            type: 'bar',
            stack: 'x',
            data: [5, 20, 36, 10, 10],
            itemStyle: {
                color: {
                    x: 0,
                    y: 1,
                    x2: 0,
                    y2: 0,
                    colorStops:
                        [
                            { offset: 0, color: 'rgba(52, 163, 224, 0.08)' },
                            { offset: 1, color: 'rgba(26, 132, 191, 1)' },
                        ],

                    global: false // 缺省为 false
                }
            }
        },

    ]
};

myChartBar.setOption(optionBar);


// 雷达图

var myChartRadar = echarts.init(document.getElementById('chartRadar'),);
optionRadar = {
    title: {
        text: '历次检测情况',
        top: 10,
        left: 10
    },
    tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(0,0,250,0.2)'
    },
    legend: {
        type: 'scroll',
        bottom: 10,
        textStyle: {
            fontSize: 24, // 设置图例字体大小
        },
        data: (function (){
            var list = [];
            for (var i = 1; i <=10; i++) {
                list.push('第'+i+'次');
            }
            return list;
        })()
    },
    visualMap: {
        top: 'middle',
        right: 10,
        color: ['red', 'yellow'],
        calculable: true
    },
    radar: {
        indicator: [
            { text: '咬伤'},
            { text: '开路'},
            { text: '短路'},
            { text: '支线'},
            { text: '杂铜'}
        ],
        name: {
            textStyle: {
                fontSize: 24, // 设置指示器标签的字体大小
                fontWeight: 'bold',
                color: 'black',
            }
        }
    },
    series: (function (){
        var series = [];
        for (var i = 1; i <= 10; i++) {
            series.push({
                name: '',
                type: 'radar',
                symbol: 'none',
                lineStyle: {
                    width: 2
                },
                emphasis: {
                    areaStyle: {
                        color: 'rgba(0,250,0,0.3)'
                    }
                },
                data: [{
                    value: [
                        (40 - i) * 10,
                        (38 - i) * 4 + 60,
                        i * 5 + 10,
                        i * 9,
                        i * i /2
                    ],
                    name: '第'+i+'次'
                }]
            });
        }
        return series;
    })()
};

myChartRadar.setOption(optionRadar);