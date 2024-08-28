import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'Hello';

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
        .onClick(() => {
          router.pushUrl(
            {
              url: 'pages/Homepage',
            },
            router.RouterMode.Standard,
          (error) => {
            console.log("s", error);
          })
        })
    }
    .height('100%')
    .width('100%')
  }
}