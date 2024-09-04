// 页面消息通知
import { NoticeController } from '../controllers/NoticeController'


@Entry
@Component
export struct Notice {
  @State show: boolean = false
  @State message: string = ''
  @State selectedIdx: number = 0
  imgName: Array<string> = [
      'app.media.success',
      'app.media.fail',
      'app.media.warning'
  ]
  public noticeController: NoticeController | null = null;

  @Builder NoticeSpan() {
    Flex({justifyContent: FlexAlign.Center}) {
      Row() {
        Image($r(this.imgName[this.selectedIdx]))
          .width(26)
          .height(26)
          .align(Alignment.Center)
          .margin({right: 10})
        Text(this.message)
          .fontSize(16)
          .height(40)
          .textAlign(TextAlign.Center)
      }
        .borderRadius(6)
        .shadow({ radius: 16, color: Color.Gray, offsetX: 0, offsetY: 6 })
        .padding({left: 8, right: 8})
    }
    .width('100%')
  }

  aboutToAppear(): void {
    if (this.noticeController)
      this.noticeController.attach(this)
  }

  update(value: string, selectedIdx: number): void {
    this.message = value
    this.selectedIdx = selectedIdx
    this.show = true
  }

  close(): void {
    this.show = false;
  }

  success(value: string): void {
    this.update(value, 0)
  }

  fail(value: string): void {
    this.update(value, 1)
  }

  warning(value: string): void {
    this.update(value, 2)
}

  build() {
    Flex({alignItems: ItemAlign.Center}) {
      this.NoticeSpan()
    }
    .width('100%')
    .height('100%')
    .visibility(this.show ? Visibility.Visible : Visibility.None)
    .position({top: 0, left: 0})
    .zIndex(999)
  }
}