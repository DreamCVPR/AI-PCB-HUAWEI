import { noticeTime, requestTime, ThemeColor } from '../common/settings';
import { LoadingDialog, router } from '@kit.ArkUI';
import { Response, UserInfo } from '../common/classes';
import { CustomContentDialog } from '@kit.ArkUI';
import { resetPwd } from '..//api/user';
import promptAction from '@ohos.promptAction'



@Entry
@Component


export struct ChangePwd {

  @StorageLink("userInfo") userInfo: UserInfo = new UserInfo();
  @State oldPwd: string = '';
  @State newPwd: string = '';
  @State newPwdAffirm: string = '';
  @State handlePopup: boolean = false;
  @State TextError: string = '';

  @Builder TopBar() {
    Row() {
      Flex() {
        Text("修改密码")
          .fontColor(ThemeColor.NavConfig['FontColor'])
          .fontSize(20)
          .fontWeight(400)
          .textAlign(TextAlign.Start)
          .margin({ left: 10+27 })
        Blank()
        Image($r('app.media.left_arrow'))
          .fillColor(ThemeColor.NavConfig['FontColor'])
          .height(25)
          .width(25)
          .margin({ left: 2 })
          .position({bottom: -1})
          .onClick(()=>{
            router.back()
          })
      }
    }
    .width('100%')
    .height(AppStorage.get('statusBarHeight') as number - 30)
    .backgroundColor(ThemeColor.NavConfig['BackgroundColor'])
    .padding({
      left: 10,
      right: 10,
      top: 30,
      bottom: 0
    })
  }

  build(){
    Column(){
      this.TopBar()

      Row(){
        Text('原密码:')
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(80)
          .height(40)
          .padding({
            left: 20,
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topLeft: 20,
            bottomLeft: 20
          })


        TextInput({placeholder: '请输入旧密码...', text: this.oldPwd })
          // .onChange((value)=>{
          //   // if (value == this.userInfo.loginPwd){
          //     this.oldPwd = value
          //   // }
          //
          // })
          .onChange((value: string) => {
            this.oldPwd = value
          })
          .type(InputType.Password)
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(290)
          .height(40)
          .padding({
            right: 20
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topRight: 20,
            bottomRight: 20
          })
      }
      .margin({
        top: 30,
        bottom: 10
      })

      Row(){
        Text('新密码:')
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(80)
          .height(40)
          .padding({
            left: 20,
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topLeft: 20,
            bottomLeft: 20
          })


        TextInput({placeholder: '请输入新的密码...', text: this.newPwd })
          .onChange((value: string) => {
            this.newPwd = value
          })
          .type(InputType.Password)
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(290)
          .height(40)
          .padding({
            right: 20
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topRight: 20,
            bottomRight: 20
          })
      }
      .margin({
        top: 10,
        bottom: 10
      })

      Row(){
        Text('确认:')
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(80)
          .height(40)
          .padding({
            left: 20,
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topLeft: 20,
            bottomLeft: 20
          })


        TextInput({placeholder: '请确认新密码...', text: this.newPwdAffirm })
          .onChange((value: string) => {
            this.newPwdAffirm = value
          })
          // .showUnderline(true)
          .showError(this.TextError)
          .type(InputType.Password)
          .margin({top: 0})
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(290)
          .height(40)
          .padding({
            top: 10,
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topRight: 20,
            bottomRight: 20
          })
      }
      .alignItems(VerticalAlign.Top)
      .margin({
        top: 10
      })

      Row(){
        Button('取消')
          .fontColor(Color.Black)
          .width(100)
          .backgroundColor(Color.White)
          .border({
            color: Color.White,
            width:1
          })
          .onClick(()=>{
            router.back()
          })
        Blank()
        Button('确认')
          .onClick(()=>{
            if (this.newPwdAffirm == this.newPwd) {
              this.TextError = ''
              if (this.oldPwd == this.userInfo.loginPwd){
                resetPwd({loginPwd: this.newPwd})
                  .then((res: Response) => {
                    if (res.status === 200) {
                      this.userInfo.loginPwd = this.newPwd;
                      promptAction.showToast({
                        message:'密码修改成功',
                        duration:1600,
                        bottom:120
                      })
                      router.back();
                    }
                  })
              }
              else{
                promptAction.showToast({
                  message:'旧密码不正确，请重新输入！',
                  duration:1600,
                  bottom:120,
                })

              }
            } else {
              promptAction.showToast({
                message:'请确认两次密码相同！',
                duration:1600,
                bottom:120
              })
            }
            // else if(){
            //
            // }
          })
          // .bindPopup(this.handlePopup, {
          //   message: '您输入的旧密码不正确'
          // })
          .width(100)
      }
      .position({ y:330})
      .width('100%')
      .height(60)
      .padding({
        left: 12,
        right: 12
      })

    }
    .backgroundColor('rgb(220,220,220)')
    .width('100%')
    .height('100%')



    }
    //     Text('密码修改页面')
    //       .width('100%')
    //       .height(80)
    //       .backgroundColor(Color.White)
    //       .padding({
    //         top: 45
    //       })
    //   }
    // .backgroundColor('rgb(220,220,220)')
    // .width('100%')
    // .height('100%')
    // }
  }