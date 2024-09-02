import { router } from '@kit.ArkUI';
import { UserInfo } from '../common/classes';

@Entry
@Component
export struct Settings {

  private userInfo?: UserInfo;

  aboutToAppear(): void {
    if (AppStorage.get('token') === '')
      router.replaceUrl({url: 'pages/Login'})
    this.userInfo = AppStorage.get('userInfo');
    console.log(JSON.stringify(this.userInfo))
  }


  @Builder
  UserInfo (): void {
    Column() {
      Row() {
        Image($r('app.media.logo'))
          .width(120)
          .height(120)
          .borderRadius('25%')
          .backgroundColor('#000000')
      }
      Text(this.userInfo?.userName)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
  build() {
    RelativeContainer() {
      this.UserInfo();
      // Text(this.message)
      //   .id('HelloWorld')
      //   .fontSize(50)
      //   .fontWeight(FontWeight.Bold)
      //   .alignRules({
      //     center: { anchor: '__container__', align: VerticalAlign.Center },
      //     middle: { anchor: '__container__', align: HorizontalAlign.Center }
      //   })
      Button('清除token')
        .onClick(() => {
          AppStorage.set('token', '');
          router.replaceUrl({url: 'pages/Login'})
        })
    }
    .height('100%')
    .width('100%')
  }
}