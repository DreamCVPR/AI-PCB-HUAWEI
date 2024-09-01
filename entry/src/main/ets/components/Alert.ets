// 通用告警提示

const statusMap: Map<number, string> = new Map([
  [0, '执行失败'],
  [1, '执行成功'],
])

@CustomDialog
struct AlertContent {
  controller?: CustomDialogController
  status: number = 0

  build() {
    Text(statusMap[this.status])
      .fontSize(20)
  }
}

@Entry
@Component
export struct Alert {
  status: number = 0
  alertDialog: CustomDialogController | null = new CustomDialogController({
    builder: AlertContent({
      status: this.status,
    }),
    openAnimation: {
      duration: 1000,
    },
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: {dx: 0, dy: -20},
    gridCount: 4,
    backgroundColor: '#ffffff',
    cornerRadius: 4,
  })

  openAlert(): void {
    this.alertDialog?.open()
  }

  aboutToDisappear() {
    this.alertDialog = null // 将dialogController置空
  }

  build() {

  }
}