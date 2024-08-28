import router from '@ohos.router';
import store from '../utils/store'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State store: store = new store();

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
      Button('nihao')
        .onClick(async () => {
          await store.ww();
          // router.pushUrl(
          //   {
          //     url: 'pages/Homepage',
          //   },
          //   router.RouterMode.Standard,
          //
          // (error) => {
          //   console.log("s", error);
          // })
        })
    }
    .height('100%')
    .width('100%')
  }
}