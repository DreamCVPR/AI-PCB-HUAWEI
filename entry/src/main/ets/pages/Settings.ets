import { router } from '@kit.ArkUI';

@Entry
@Component
export struct Settings {
  @State message: string = '我的';
  @StorageLink("token") token: string = "";

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      Button('清除token')
        .onClick(() => {
          this.token = '';
          router.replaceUrl({url: 'pages/Login'})
        })
    }
    .height('100%')
    .width('100%')
  }
}