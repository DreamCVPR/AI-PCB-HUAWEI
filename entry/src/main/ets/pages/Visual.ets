import router from '@ohos.router';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';


@Entry
@Component
export struct Visual {
  @State message: string = '图表可视化页';
  controller: webview.WebviewController = new webview.WebviewController();
  @StorageLink("token") token: string = '';

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
          .onPageEnd(e => {
            console.log("New page loaded: " + e.url);
          })
      }
    }
  }
}