import { router } from '@kit.ArkUI';
import picker from '@ohos.file.picker';
import { UserInfo } from '../common/classes';
import { FileUtils } from  '../utils/FileUtils';
import { addImg, detect, getTaskImg, removeImg } from '../api/taskImg';
import {baseUrl} from '../utils/request';
import { getUserInfo,updateUser,changeImg,resetPwd } from '..//api/user';


@Entry
@Component
export struct Settings {
  COMPRESS_FILE: string = "/file/compress/"
  ORIGIN_FILE: string = "/file/download/"


  @StorageLink("userInfo") userInfo: UserInfo = new UserInfo();
  @State introduce: string = '';
  @State userName: string = '';
  @State userPhone: string = '';
  @State loginPwd: string = '';
  @State img: string = '..';
  @State ImgList: Array<object> = [];
  @State originImgRealSize: Array<object> = [];


  aboutToAppear(): void {
    if (AppStorage.get('token') === '')
      router.replaceUrl({url: 'pages/Login'})
    console.log(JSON.stringify(this.userInfo))
  }


  @Builder
  UserInfo (): void {
    Column() {
      Image(this.userInfo?.userImg ? baseUrl+this.COMPRESS_FILE+this.userInfo?.userImg : $r('app.media.logo'))
        .onClick(() => {
          FileUtils.chooseImage(1).then(imgList =>{
            if (imgList[0].length > 0) {
              changeImg({"file": imgList[0][0]})
                .then((res: object) => {
                  this.userInfo.userImg = res['result']
                  console.log("增加taskImg成功:"+  JSON.stringify(res));
                })
            }
          })
          console.log('上传图像');
        })
        .width(120)
        .height(120)
          // .backgroundColor('rgb(220,220,220)')
        .border({
          width: 1,
          color: Color.White,
          style: BorderStyle.Solid
        })
        .borderRadius(60)
        .objectFit(ImageFit.Cover)
        Row(){
          Text('用户名:  ')
            .fontSize(16)
            .fontWeight(700)
            .fontColor(Color.Black)
            .width(100)
            .height(40)
            .padding({
              left: 20,
            })
            .backgroundColor(Color.White)
            .borderRadius({
              topLeft: 20,
              bottomLeft: 20
            })

          TextInput({placeholder: '请输入用户名...', text: this.userInfo.userName })
            .onClick(()=>{
              updateUser({'userName': this.userInfo.userName, 'userPhone': '' })
            })
            .fontSize(16)
            .fontWeight(700)
            .fontColor(Color.Black)
            .width(250)
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
          top: 20,
          bottom: 10
        })

      Row(){
        Text('手机号:')
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(100)
          .height(40)
          .padding({
            left: 20,
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topLeft: 20,
            bottomLeft: 20
          })
        TextInput({placeholder: '请输入您的手机号...', text: this.userInfo.userPhone })
          .onClick(()=>{
            updateUser({'userName': '', 'userPhone': this.userInfo.userPhone })
          })
          .type(InputType.PhoneNumber)
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(250)
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
        Text('密码:')
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(100)
          .height(40)
          .padding({
            left: 20,
          })
          .backgroundColor(Color.White)
          .borderRadius({
            topLeft: 20,
            bottomLeft: 20
          })
        TextInput({placeholder: '请输入您的密码...', text: this.userInfo.userPhone })
          .onClick(()=>{
            resetPwd({'loginPwd': this.userInfo.loginPwd })
          })
          .type(InputType.Password)
          .fontSize(16)
          .fontWeight(700)
          .fontColor(Color.Black)
          .width(250)
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

      // TextInput({
      //   placeholder: '个人简介:  ',
      //   text: $$this.introduce
      // })
      TextArea({ placeholder: '个人简介...', text: this.introduce })
        .textAlign(TextAlign.Start)
        .textOverflow(TextOverflow.Ellipsis)
        .maxLines(3)
        .onSubmit(()  =>  {})
        .margin({
        top: 10,
        bottom: 10
      })
      .fontColor(Color.Black)
      .width(350).height(80)
      .padding({
        top: 15,
        bottom: 5,
        left: 10,
        right: 10
      })
      .backgroundColor(Color.White)
      .borderRadius(20)

    }
    .justifyContent(FlexAlign.SpaceAround)
    .width('100%')
    .height('30%')
    // .backgroundColor('rgb(220,220,220)')
  }

  build() {
    // RelativeContainer() {
      Scroll(){
        Column(){
          this.UserInfo()
          // Text(this.message)
          //   .id('HelloWorld')
          //   .fontSize(50)
          //   .fontWeight(FontWeight.Bold)
          //   .alignRules({
          //     center: { anchor: '__container__', align: VerticalAlign.Center },
          //     middle: { anchor: '__container__', align: HorizontalAlign.Center }
          //   })
          Button('退出登录')
            .onClick(() => {
              AppStorage.set('token', '');
              router.replaceUrl({url: 'pages/Login'})
            })
            .margin({
              top: 40
            })
            .width(350)
            .height(40)
          // .width('100')

        }
        .justifyContent(FlexAlign.SpaceAround)
        .backgroundColor('rgb(220,220,220)')
        .width('100%')
        .height('100%')
        // .padding(10)
      }
    }


  // }

}