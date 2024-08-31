import { login } from '../api/account';
import { Response } from '../common/classes';

// 初始化存储的token
PersistentStorage.persistProp('token', '')

@Entry
@Component
export struct Login {
  @State username: string = ''
  @State password: string = ''
  @State isValidUsername: boolean = true;
  @State isValidPassword: boolean = true;
  @StorageLink("token") token: string = "";

  logo: string = 'app.media.logo'

  build() {
    Column() {
      Row() {
        Image($r(this.logo))
          .width(80)
          .height(80)
          .align(Alignment.Center)
      }
      .margin({top: 180})
      Column() {
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .height(46)
          .width('80%')
          .onChange((value: string) => {
            if (value.length > 16)
              this.isValidUsername = false; else
              this.isValidUsername = true;
            this.username = value
          })
          .margin({bottom: 20})
          .backgroundColor('rgb(230, 230, 230)')
          .borderRadius(16)

        TextInput({ placeholder: '请输入密码', text: this.username })
          .height(46)
          .width('80%')
          .type(InputType.Password)
          .onChange((value: string) => {
            if (value.length > 16)
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
        Button('登录')
          .width(200)
          .onClick(() => {
            login()
              .then((res: object) => {
                console.log("获取任务成功:"+  JSON.stringify(res));
                this.token = res["result"];
              })
              .catch((err: object) => {
                console.log("获取任务失败:" + JSON.stringify(err))
              })
          })
      }
      .margin({top: 20})
    }
    .width('100%')
    .height('100%')
  }
}