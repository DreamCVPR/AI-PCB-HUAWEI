
window.onload = async function () {
    params.getTask().then((res) => {
        params.print(res)
        document.querySelector("#box1 .boxValue").textContent = res.userTaskCount;
        document.querySelector("#box2 .boxValue").textContent = res.userImgCount;
        document.querySelector("#box3 .boxValue").textContent = res.sumDefect;
        document.querySelector("#box4 .boxValue").textContent = ((res.maxDefect/res.sumDefect)*100).toFixed(1) + '%';
        drawPie(res)
        params.print(res.radarList[0])
        drawRadar(res.radarList)
    });

}

function drawPie(params) {
    var colors = ["#2E4053  ", "#5D6D7E  ", "#AAB7B8  ","#117A65 ","#D5D8DC"]

    var myChartPie = echarts.init(document.getElementById('chartPie'),);

    //累计监测数据
    pieData = [
        { value: params.mouseBiteDefect, name: '鼠咬' },
        { value: params.openCircuitDefect, name: '开路' },
        { value: params.shortDefect, name: '短路' },
        { value: params.spurDefect, name: '毛刺' },
        { value: params.spuriousCopperDefect, name: '伪铜' }
    ];
    sum = params.sumDefect;


    function getOptionPie(data) {
        return optionPie = {
            title: {
                text: "累计检测统计",
                x: "center",
                textStyle: {
                    fontSize: 48,
                    color: 'black',
                },
            },
            color: colors,
            legend: {
                x: 'center',
                bottom: 0,
                data:['鼠咬', '开路', '短路', '毛刺', '伪铜'],
                itemHeight: 36,//图例图标的高度
                itemWidth:36,
                itemGap: 36,
                textStyle: {
                    fontSize: 36,
                    color: 'black',
                },
            },
            series: [
                {
                    name: 'Access From',
                    type: 'pie',
                    radius: ['45%', '75%'],
                    avoidLabelOverlap: false,
                    itemStyle: {
                        borderRadius: 10000,
                        borderColor: '#fff',
                        borderWidth: 2
                    },
                    label: {
                        show: false,
                        position: "outside",
                    },
                    emphasis: {
                        label: {
                            show: true,
                            fontSize: 40,
                            fontWeight: 'bold',
                            formatter: function (pieData) {
                                return  pieData.name + '\n' + (pieData.value/sum*100).toFixed(1) +'%'
                            }
                        }
                    },
                    labelLine: {
                        show: true,
                        lineStyle: {
                            color: 'black',
                            width: 5,
                            type: 'solid'
                        }
                    },
                    data: pieData,
                    itemStyle: {
                        normal: {
                            shadowBlur: 20,  // 阴影的模糊程度
                            shadowOffsetX: 10,  // 阴影在水平方向的偏移
                            shadowOffsetY: 10,  // 阴影在垂直方向的偏移
                            shadowColor: 'rgba(0, 0, 0, 0.5)'  // 阴影颜色
                        },
                    }
                }
            ]
        };
    }
    myChartPie.setOption(getOptionPie([]), true);
    myChartPie.setOption(getOptionPie(pieData), true);
}

function drawRadar(params) {
    var detectData = params
    // 雷达图

    var myChartRadar = echarts.init(document.getElementById('chartRadar'),);
    optionRadar = {
        title: {
        },
        tooltip: {
            trigger: 'item',
            backgroundColor: 'rgba(0,0,250,0.2)'
        },
        legend: {
            type: 'scroll',
            bottom: 10,
            itemHeight: 36,//图例图标的高度
            itemWidth:36,
            itemGap: 36,
            textStyle: {
                fontSize: 36, // 设置图例字体大小
            },
            data: (function (){
                var list = [];
                for (var i = 1; i <= detectData.length; i++) {
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
                { text: '鼠咬'},
                { text: '开路'},
                { text: '短路'},
                { text: '毛刺'},
                { text: '伪铜'}
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
            for (var i = 1; i <= detectData.length; i++) {
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
                        value: detectData[i-1],
                        name: '第'+i+'次'
                    }]
                });
            }
            return series;
        })()
    };

    myChartRadar.setOption(optionRadar, true);
}