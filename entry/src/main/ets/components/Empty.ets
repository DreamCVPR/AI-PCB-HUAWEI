// 空状态

@Entry
@Component
export struct Empty {
  build() {
    Column() {
      Image($r('app.media.empty'))
        .width(100)
        .height(100)
      Text('暂无数据')
        .fontSize(20)
        .margin({top: 14})
        .fontColor('rgb(160, 160, 160)')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}