import router from '@ohos.router';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
export struct Visual {
  @State message: string = '图表可视化页';
  controller: webview.WebviewController = new webview.WebviewController();
  @StorageLink("token") token: object | null = null;

  aboutToAppear(): void {
    if (!this.token)
      router.replaceUrl({url: 'pages/Login'})
  }

  build() {
    RelativeContainer() {
      Column() {
        Web({ src: $rawfile('chart/chart.html'), controller: this.controller })
          .javaScriptAccess(true)
          .onPageEnd(e => {
            try {
              this.controller.runJavaScript('test()')
                .then((result) => {
                  console.log('result: ' + result);
                })
                .catch((error: BusinessError) => {
                  console.error("error: " + error);
                })
              if (e) {
                console.info('url: ', e.url);
              }
            } catch (error) {
              console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
      }
    }


    //   Text(this.message)
    //     .id('HelloWorld')
    //     .fontSize(50)
    //     .fontWeight(FontWeight.Bold)
    //     .alignRules({
    //       center: { anchor: '__container__', align: VerticalAlign.Center },
    //       middle: { anchor: '__container__', align: HorizontalAlign.Center }
    //     })
    // }

  }
}