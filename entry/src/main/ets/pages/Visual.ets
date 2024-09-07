import router from '@ohos.router';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { getTasks } from '../api/service';
import { MaxSelected } from '@kit.MediaLibraryKit';

class Params {
  token?: string = AppStorage.get("token")
  constructor() {
  }

  getTask() {
    return getTasks().then((res: object)=>{
      const data: Array<object> = res["result"];
      // interface ChartData {
      //   userTaskCount: number;
      //   taskName: string;
      //   taskCount: Array<number>;
      // }
      interface ChartData {
        userTaskCount: number;
        userImgCount: number;
        mouseBiteDefect: number;
        openCircuitDefect: number;
        shortDefect: number;
        spurDefect: number;
        spuriousCopperDefect: number;
        sumDefect: number;
        maxDefect: number;
        radarList: number[][];
      }

      const chartData: ChartData = {
        userTaskCount: 0,  // 正确初始化
        userImgCount: 0,
        mouseBiteDefect: 0,
        openCircuitDefect: 0,
        shortDefect: 0,
        spurDefect: 0,
        spuriousCopperDefect: 0,
        sumDefect: 0,
        maxDefect: 0,
        radarList: [],
      };

      chartData.userTaskCount = data.length;
      for(let i = 0; i < chartData.userTaskCount; i++){
        chartData.userImgCount = chartData.userImgCount + data[i]["countDetectImg"]
        chartData.mouseBiteDefect = chartData.mouseBiteDefect + data[i]["countDefect"]["mouse_bite"]
        chartData.openCircuitDefect = chartData.openCircuitDefect + data[i]["countDefect"]["open_circuit"]
        chartData.shortDefect = chartData.shortDefect + data[i]["countDefect"]["short"]
        chartData.spurDefect = chartData.spurDefect + data[i]["countDefect"]["spur"]
        chartData.spuriousCopperDefect = chartData.spuriousCopperDefect + data[i]["countDefect"]["spurious_copper"]
        chartData.radarList.push([data[i]["countDefect"]["mouse_bite"], data[i]["countDefect"]["open_circuit"], data[i]["countDefect"]["short"], data[i]["countDefect"]["spur"], data[i]["countDefect"]["spurious_copper"]]);
      }
      chartData.sumDefect = chartData.mouseBiteDefect + chartData.openCircuitDefect + chartData.shortDefect + chartData.spurDefect + chartData.spuriousCopperDefect
      chartData.maxDefect = Math.max(chartData.mouseBiteDefect, chartData.openCircuitDefect, chartData.shortDefect, chartData.spurDefect, chartData.spuriousCopperDefect)
      return chartData
    }).catch((err: object) => {
      return []
    })
  }

  getToken() {
    return this.token
  }

  print(data: object) {
    console.log(JSON.stringify(data))
  }
}

@Entry
@Component
export struct Visual {
  @State message: string = '图表可视化页';
  controller: webview.WebviewController = new webview.WebviewController();
  @StorageLink("token") token: string = '';
  params = new Params()

  aboutToAppear(): void {
    if (this.token === '') {
      router.replaceUrl({ url: 'pages/Login' });
    } else {
      // 通过重新实例化控制器来清除缓存
      this.controller = new webview.WebviewController();
    }
  }

  build() {
    RelativeContainer() {
      Column() {
        Web({ src: $rawfile('chart/chart.hml'), controller: this.controller })
          .javaScriptAccess(true)
          .javaScriptProxy({
            object: this.params,
            name: "params",
            methodList: ["getToken", "print","getTask"],
      //      asyncMethodList: [""],
            controller: this.controller,
          })
          .onPageEnd(e => {
            console.log("New page loaded: " + e.url);
          })
      }
    }
  }
}