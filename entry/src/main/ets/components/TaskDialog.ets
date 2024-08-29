
@CustomDialog
export struct TaskDetail {
  // 用于父子组件双向通信
  @Link taskName: string

  controller?: CustomDialogController;
  // 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在所有controller的后面
  // 定义回调函数
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text('新建检测任务').fontSize(20).margin({ top: 10, bottom: 20 })

      Column() {
        TextInput({ placeholder: '请输入任务名', text: this.taskName }).height(40).width('80%')
          .onChange((value: string) => {
            this.taskName = value
          })
          .margin({bottom: 10})
        Text('图像列表')
        Button('上传图像')
          .onClick(() => {
            console.log('上传图像');
          })
          .margin({ top:20 })
        Blank()
        Flex({ justifyContent: FlexAlign.SpaceAround }) {
          Button('取消', {type: ButtonType.Normal, stateEffect: true})
            .onClick(() => {
              this.controller?.close()
              this.cancel()
            })
            .fontColor(Color.Black)
            .backgroundColor('#ffffff')
            .borderWidth(1)
            .borderColor('#ffffff')
            .borderRadius(4)
            .borderRadius(4)
            .height(36)
            .width(120)

          Button('确定', {type: ButtonType.Normal, stateEffect: true})
            .onClick(() => {
              if (this.controller != undefined) {
                this.controller?.close()
                this.confirm()
              }
            })
            .backgroundColor('#0A59F7')
            .borderRadius(4)
            .height(36)
            .width(120)
        }
      }
      .height('80%')

    }.borderRadius(10)
    .height(400)
  }
}

@Entry
@Component
export struct TaskDialog {
  @State taskName: string = '';
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TaskDetail({
      cancel: this.onCancel,
      confirm: this.onAccept,
      taskName: $taskName,
    }),
    cancel: this.exitApp,
    autoCancel: false,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 8,
    customStyle: false
  })


  // 在自定义组件即将析构销毁时销毁组件
  aboutToDisappear() {
    this.taskName = '';
    this.dialogController = null;
  }

  onCancel() {
    this.taskName = '';
    this.dialogController = null;
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  exitApp() {
    console.info('Click the callback in the blank area')
  }

  build() {
    Column() {
      Image($r('app.media.add'))
        .width(26)
        .height(26)
        .onClick(() => {
          this.dialogController?.open();
        })

    }.margin({right: 4})
  }
}