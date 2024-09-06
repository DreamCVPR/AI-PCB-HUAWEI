// 页面加载
import { ThemeColor } from '../common/settings'

@Component
export struct Loading {

  @Prop show: boolean = false

  build() {
    Flex({alignItems: ItemAlign.Center}) {
      LoadingProgress()
        .color(ThemeColor.LoadingColor)
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