// 页面加载

@Component
export struct Loading {

  @Prop show: boolean = false

  build() {
    Flex({alignItems: ItemAlign.Center}) {
      LoadingProgress()
        .color("#64A4E0")
        .layoutWeight(1)
        .width("10%")
        .height("10%")
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(255, 255, 255, 0.2)')
    .visibility(this.show ? Visibility.Visible : Visibility.None)
    .position({top: 0, left: 0})
    .zIndex(100)
  }
}