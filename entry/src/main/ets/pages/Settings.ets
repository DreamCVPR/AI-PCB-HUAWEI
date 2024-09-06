import { router } from '@kit.ArkUI';
import { UserInfo } from '../common/classes';

@Entry
@Component
export struct Settings {
  @State introduce: string = ''

  @Link openEdit: boolean;
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
        Image($r('app.media.logo'))
          .width(120)
          .height(120)
      // .backgroundColor('rgb(220,220,220)')
      .border({
        width: 1,
        color: Color.White,
        style: BorderStyle.Solid
      })
      .borderRadius(60)

      Text(){
          Span('用户名:  ').fontSize(16).fontWeight(700)
          Span(this.userInfo?.userName)
      }
        .margin({
          top: 20,
          bottom: 10
        })
      .fontColor(Color.Black)
      .width(350)
      .height(40)
      .padding({
        left: 20,
        right: 20
      })
      .backgroundColor(Color.White)
      .borderRadius(20)
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