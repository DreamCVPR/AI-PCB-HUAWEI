import { router } from '@kit.ArkUI';
import picker from '@ohos.file.picker';
import { Response, UserInfo } from '../common/classes';
import { FileUtils } from  '../utils/FileUtils';
import { addImg, detect, getTaskImg, removeImg } from '../api/taskImg';
import {baseUrl} from '../utils/request';
import { getUserInfo,updateUser,changeImg} from '..//api/user';
import { PersonalController } from '../controllers/PersonalController';
import { JSON } from '@kit.ArkTS';


@Entry
@Component
export struct Settings {
  COMPRESS_FILE: string = "/file/compress/"
  ORIGIN_FILE: string = "/file/download/"
  @Link openEdit: boolean
  public  personalController?: PersonalController


  @StorageLink("userInfo") userInfo: UserInfo = new UserInfo();
  @State introduce?: string = '';
  @State userName?: string = '';
  @State userPhone?: string = '';
  @State loginPwd?: string = '';
  @State img: string = '..';
  @State ImgList: Array<object> = [];
  @State originImgRealSize: Array<object> = [];
  @State file?: string = "";

  @State isFileChange: boolean = false
  @State isInfoChange: boolean = false


  aboutToAppear(): void {
    if (AppStorage.get('token') === '')
      router.replaceUrl({url: 'pages/Login'})
    if (this.personalController)
      this.personalController.attach(this)
    this.introduce = this.userInfo.userInfo
    this.userName = this.userInfo.userName
    this.userPhone = this.userInfo.userPhone
    this.loginPwd = this.userInfo.loginPwd
    this.file = this.userInfo.userImg
    console.log(JSON.stringify(this.userInfo))
  }

  onSave() {
    if (this.isFileChange) {
      changeImg({"file": this.file})
        .then((res: object) => {
          this.userInfo.userImg = res['result']
          this.isFileChange = false
          console.log("增加taskImg成功:"+  JSON.stringify(res));
        })
        .catch(()=>{
          this.isFileChange = false
        })
    }
    if (this.isInfoChange) {
      updateUser({
        userName: this.userName,
        userPhone: this.userPhone,
        userInfo: this.introduce
      }, '更新信息成功')
        .then((res: Response) => {
          if (res.status === 200) {
            this.userInfo.userName = this.userName;
            this.userInfo.userPhone = this.userPhone
            this.userInfo.userInfo = this.introduce
            this.isInfoChange = false
          }
        })
        .catch(()=>{
          this.isInfoChange = false
        })
    }


  }

  @Builder
  UserInfo (): void {
    Column() {
      Stack(){
        Image(this.file ? (this.isFileChange ? `data:image/jpeg;base64,`+this.file : baseUrl+this.COMPRESS_FILE+this.file): $r('app.media.logo'))
          .width("100%")
          .height(230)
          // .backgroundColor('#73000000')
        // .backgroundImage(baseUrl+this.COMPRESS_FILE+this.userInfo?.userImg)
          .objectFit(ImageFit.Cover)
          .opacity(0.2)
        Image(this.file ? (this.isFileChange ? `data:image/jpeg;base64,`+this.file : baseUrl+this.COMPRESS_FILE+this.file): $r('app.media.logo'))
          .onClick(() => {
            if (this.openEdit) {
              FileUtils.chooseImage(1, 20).then(imgList =>{
                if (imgList[0].length > 0) {
                  this.file = imgList[0][0]
                  this.isFileChange = true
                }
              })
              console.log('上传图像');
            }
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

      }.margin({
        bottom: 5
      })

        Row(){
          Text(`用户名:  `)
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
          if (!this.openEdit) {
            Text(this.userInfo.userName)
              .fontSize(16)
              .fontWeight(700)
              .fontColor(Color.Black)
              .width(290)
              .height(40)
              .padding({
                right: 20,
                left: 16
              })
              .backgroundColor(Color.White)
              .borderRadius({
                topRight: 20,
                bottomRight: 20
              })
          }
          else {
            TextInput({ placeholder: '请输入用户名...', text: this.userInfo.userName })
              .onChange((value) => {
                this.userName = value;
                this.isInfoChange = true
              })
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
        }
        .margin({
          top: 20
        })

      Row(){
        Text('手机号:')
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
        if (!this.openEdit) {
          Text(this.userPhone )
            .fontSize(16)
            .fontWeight(700)
            .fontColor(Color.Black)
            .width(290)
            .height(40)
            .padding({
              right: 20,
              left: 16
            })
            .backgroundColor(Color.White)
            .borderRadius({
              topRight: 20,
              bottomRight: 20
            })
        }
        else {
          TextInput({ placeholder: '请输入您的手机号...', text: this.userPhone })
            .onChange((value) => {
              this.userPhone = value
              this.isInfoChange = true
            })
            .type(InputType.PhoneNumber)
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
        }
          .margin({
            top: 10,
            bottom: 10
          })



      // Row(){
      //   Text('密码:')
      //     .fontSize(16)
      //     .fontWeight(700)
      //     .fontColor(Color.Black)
      //     .width(100)
      //     .height(40)
      //     .padding({
      //       left: 20,
      //     })
      //     .backgroundColor(Color.White)
      //     .borderRadius({
      //       topLeft: 20,
      //       bottomLeft: 20
      //     })
      //   TextInput({placeholder: '请输入您的密码...', text: this.userInfo.userPhone })
      //     .onChange((value)=>{
      //       this.loginPwd = value;
      //     })
      //     .type(InputType.Password)
      //     .fontSize(16)
      //     .fontWeight(700)
      //     .fontColor(Color.Black)
      //     .width(250)
      //     .height(40)
      //     .padding({
      //       right: 20
      //     })
      //     .backgroundColor(Color.White)
      //     .borderRadius({
      //       topRight: 20,
      //       bottomRight: 20
      //     })
      // }
      // .margin({
      //   top: 10,
      //   bottom: 10
      // })

      // TextInput({
      //   placeholder: '个人简介:  ',
      //   text: $$this.introduce
      // })
      if (this.openEdit){
        TextArea({ placeholder: '个人简介...', text: this.introduce })
          .onChange((value)=>{
            this.introduce = value
            this.isInfoChange = true
          })
          .align(Alignment.TopStart)
          .textOverflow(TextOverflow.Ellipsis)
          .maxLines(3)
          .onSubmit(()  =>  {})
          .margin({
            bottom: 10
          })
          .fontColor(Color.Black)
          .width(370).height(80)
          .padding({
            top: 15,
            bottom: 5,
            left: 10,
            right: 10
          })
          .backgroundColor(Color.White)
          .borderRadius(20)
      }else{
        Text(this.introduce)
          // .textAlign(TextAlign.Start)
          // .textOverflow(TextOverflow.Ellipsis)
          .maxLines(3)
          // .onSubmit(()  =>  {})
          .margin({
            bottom: 10
          })
          .fontColor(Color.Black)
          .width(370).height(80)
          .padding({
            top: 15,
            bottom: 5,
            left: 10,
            right: 10
          })
          .backgroundColor(Color.White)
          .borderRadius(20)
          .align(Alignment.TopStart)
      }


    }
    // .justifyContent(FlexAlign.SpaceAround)
    .width('100%')
    .height(300)
    // .backgroundColor('rgb(220,220,220)')
  }

  build() {
    // RelativeContainer() {
    //   Scroll(){
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
            .position({
              x:10,
              y:480
            })
            .width(370)
            .height(40)
          // .width('100')
          Row(){
              Text('修改密码')
                .onClick(() => {
                  router.pushUrl({url: 'pages/ChangePwd'})
                })

          }
          .position({
            x:300,
            y:540
          })


        }
        // .justifyContent(FlexAlign.SpaceAround)
        .backgroundColor('rgb(220,220,220)')
        .width('100%')
        .height('100%')
        // .padding(10)
      }
    //   .width('100%')
    //   .height('100%')
    // }


  // }

}