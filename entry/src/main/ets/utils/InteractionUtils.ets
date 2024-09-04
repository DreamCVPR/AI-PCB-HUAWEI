

export class InteractionUtils {

  static confirm(title: string, message: string, confirmAction: Function, cancelAction: Function = new Function(), height: number = 230) {
    AlertDialog.show(
      {
        title: title,
        message: message,
        autoCancel: true,
        alignment: DialogAlignment.Center,
        height: height,
        primaryButton: {
          value: '取消',
          fontColor: '#000000',
          backgroundColor: '#ffffff',
          action: () => {
            cancelAction()
          }
        },
        secondaryButton: {
          value: '确定',
          fontColor: '#000000',
          backgroundColor: '#ffffff',
          action: () => {
            confirmAction()
          }
        },
        cancel: () => {
          cancelAction()
        }
      })
  }
}