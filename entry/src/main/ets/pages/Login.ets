import { login } from '../api/account';
import { LoadingDialog, router } from '@kit.ArkUI';

import { UserInfo } from '../common/classes';
import { Notice } from '../components/Notice'
import { Loading } from '../components/Loading'
import { NoticeController } from '../controllers/NoticeController';
import { noticeTime, requestTime } from '../common/settings';

// 初始化存储的token
PersistentStorage.persistProp('token', '')
PersistentStorage.persistProp('userInfo', {})
PersistentStorage.persistProp('backgroundFileName', {})

@Entry
@Component
export struct Login {
  @State username: string = ''
  @State password: string = ''
  @State isValidUsername: boolean = false;
  @State isValidPassword: boolean = false;
  @State showLoading: boolean = false;
  @StorageLink("token") token: string = '';
  @StorageLink("userInfo") userInfo: UserInfo | null = null;

  private noticeController: NoticeController = new NoticeController()
  logo: string = 'app.media.logo'


  dialogControllerProgress: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '处理中...',
    }),
  })

  aboutToAppear(): void {
    if (this.token !== '')
      router.replaceUrl({url: 'pages/Index'})
  }

  build() {
    Column() {
      Loading({show: this.showLoading})
      Notice({noticeController: this.noticeController})
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
            this.showLoading = true;
            if (this.isValidUsername && this.isValidPassword) {
              login({
                loginName: this.username,
                loginPwd: this.password,
              })
                .then((res: object) => {
                  console.log("登入成功:" + JSON.stringify(res));
                  if (res['status'] === 200) {
                    this.token = res["result"]["token"];
                    this.userInfo = res["result"]
                    console.log("userInfo", JSON.stringify(this.userInfo))
                    setTimeout(() => {
                      this.showLoading = false;
                      router.replaceUrl({ url: "pages/Index" })
                    }, requestTime)
                  }
                  else {
                    setTimeout(() => {
                      this.showLoading = false;
                      this.noticeController.fail(res['message']);
                      setTimeout(() => {
                        this.noticeController.close();
                      }, noticeTime)
                    }, requestTime)
                  }
                })
                .catch((err: object) => {
                  setTimeout(() => {
                    this.showLoading = false;
                    this.noticeController.fail('登入失败');
                    setTimeout(() => {
                      this.noticeController.close();
                    }, noticeTime)
                  }, requestTime)
                })
            }
          })
          .enabled(this.isValidUsername && this.isValidPassword)
      }
      .margin({top: 20})

      Text('队名：mamba back again')
        .fontSize(12)
        .height('60%')
    }
    .width('100%')
    .height('100%')
  }
}