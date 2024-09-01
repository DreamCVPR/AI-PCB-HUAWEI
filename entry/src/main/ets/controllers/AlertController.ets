import { Alert } from '../components/Alert'


class AlertController {
  private alertComponent: Alert | null = null;

  constructor(value: Alert) {
    this.alertComponent = value
  }

  public openAlert(): void  {
    if (this.alertComponent)
      this.alertComponent.openAlert();
  }

}
//
// // 执行成功 控制器
// export const alertSuccessController: AlertController = new AlertController(
//   Alert({
//     status: 1
//   })
// )
//
// // 执行失败 控制器
// export const alertFailController: AlertController = new AlertController(
//   Alert({
//     status: 1
//   })
// )