@CustomDialog
export struct Confirm {
  @Link title: string

  controller?: CustomDialogController;

  // 取消
  cancel: () => void = () => {}

  // 确认
  conform: () => void = () => {}

  build() {
    Column() {
      Text(this.title)
        .fontSize(20)
        .margin({top: 20, bottom: 20})
    }
  }
}