import { login } from '../api/account';
import { Response } from '../common/classes';
import { router } from '@kit.ArkUI';

// 初始化存储的token
PersistentStorage.persistProp('token', '')
PersistentStorage.persistProp('userInfo', {})

@Entry
@Component
export struct Login {
  @State username: string = ''
  @State password: string = ''
  @State isValidUsername: boolean = false;
  @State isValidPassword: boolean = false;
  @StorageLink("token") token: string = "";
  @StorageLink("userInfo") userInfo: object | null = null;

  logo: string = 'app.media.logo'

  aboutToAppear(): void {
    if (this.token != '')
      router.replaceUrl({url: 'pages/Index'})
  }

  build() {
    Column() {
      Row() {
        Image($r(this.logo))
          .width(80)
          .height(80)
          .align(Alignment.Center)
      }
      .margin({top: 200})
      Column() {
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .height(46)
          .width('80%')
          .onChange((value: string) => {
            if (value.length == 0 || value.length > 16)
              this.isValidUsername = false; else
              this.isValidUsername = true;
            this.username = value
          })
          .margin({bottom: 20})
          .backgroundColor('rgb(230, 230, 230)')
          .borderRadius(16)

        TextInput({ placeholder: '请输入密码', text: this. password })
          .height(46)
          .width('80%')
          .type(InputType.Password)
          .onChange((value: string) => {
            if (value.length == 0 || value.length > 16)
              this.isValidPassword = false; else
              this.isValidPassword = true;
            this.password = value
          })
          .showPasswordIcon(true)
          .backgroundColor('rgb(230, 230, 230)')
          .borderRadius(16)
      }
      .margin({top: 20, bottom: 20})

      Flex({justifyContent: FlexAlign.Center}) {
        Button('登录', {stateEffect: this.isValidUsername && this.isValidPassword})
          .width(200)
          .onClick(() => {
            if (this.isValidUsername && this.isValidPassword) {
              login({
                loginName: this.username,
                loginPwd: this.password,
              })
                .then((res: object) => {
                  console.log("登入成功:" + JSON.stringify(res));
                  this.token = res["result"]["token"];
                  this.userInfo = res["result"]
                  console.log("userInfo", JSON.stringify(this.userInfo))
                  router.replaceUrl({ url: "pages/Index" })
                })
                .catch((err: object) => {
                  console.log("登入失败:" + JSON.stringify(err))
                })
            }
          })
          .opacity(this.isValidUsername && this.isValidPassword ? 1.0: 0.4)
      }
      .margin({top: 20})
      Blank()
      Text('队名：mamba back again')
        .fontSize(12)
    }
    .width('100%')
    .height('100%')
  }
}