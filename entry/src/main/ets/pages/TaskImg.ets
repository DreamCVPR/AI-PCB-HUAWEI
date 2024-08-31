import router from '@ohos.router';
import {baseUrl} from '../utils/request'
import { getTaskImg } from '../api/taskImg'
import { CommonConstants } from '../common/classes';

@Entry
@Component
export struct TaskImg {
  @State message: string = '检测页';
  @State taskId?: number = (router.getParams() as object)['taskId'];
  @State taskImgList: Array<object> = []
  @State originImgUrl: string = ""

  // @State taskImg: JSON;

  aboutToAppear(): void {
    this.getTaskImg()
  }

  getTaskImg() {
    getTaskImg({'taskId': this.taskId})
      .then((res: object) => {
        this.taskImgList = res['result']
        console.log("获取taskImg成功:"+  JSON.stringify(res));
      })
      .catch((err: object) => {
        console.log("获取taskImg失败:" + JSON.stringify(err))
      })
  }

  @Builder Mask(opacity: number = 0.95) {
    Row() {}.height("100%").width("100%").backgroundColor(Color.Gray).opacity(opacity)
  }

  @Builder ImgCard(img: object, index: number) {
    Column() {
      Image(baseUrl+"/file/download/image/"+img["imgUrl"])
        // .alt($r('media.LoadingProgress'))// 使用alt，在网络图片加载成功前使用占位图
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.CENTER)
      Flex({ alignItems: ItemAlign.Start }) {
      }
      .width("100%")
      .height(20)
      .position({bottom: 0})
      .backgroundColor("#5B5B66")
      .opacity(0.7)
      Text(index.toString().padStart(2, '0'))
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .position({bottom: 1, left: 3})
      if (img["isDetect"]) {
        Image($r('app.media.yes'))
          .height(15)
          .width(15)
          .position({bottom: 1, right: 3})
      }
    }
    .width('49%')
    .onClick((e)=>{
      this.originImgUrl = baseUrl+"/file/download/image/"+img["imgUrl"]
    })
    .gesture(
      LongPressGesture({fingers: 1, repeat: false, duration: 300})//fingers :触发最少手指数，默认1  repeat 是否连续触发 默认false  duration 长按多久触发，默认500
        .onAction(event=>{
          console.error('longPress: ' + JSON.stringify(event))
        })
    )
  }

  @Builder ListRow(taskImgList: Array<object>, index: number) {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      this.ImgCard(taskImgList[index], index+1)
      if (index+1 < taskImgList.length) {
        this.ImgCard(taskImgList[index+1], index+2)
      }
    }
    .width('100%')
    .padding({bottom: '2%'})
    .aspectRatio(2)
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        Row() {
        }
        .width('100%')
        .height(CommonConstants.STATUS_BAR_HEIGHT - 10)
        .backgroundColor('rgb(130, 178, 154)')
        .padding({
          left: 10,
          right: 10,
          top: 30,
          bottom: 0
        })

        Stack() {
          List({initialIndex: 0}) {
            ForEach(this.taskImgList, (item: object, index: number) => {
              if (index % 2 == 0) {
                this.ListRow(this.taskImgList, index)
              }
            })
          }
          .width('100%')
          .padding({left: 8, right: 8, top: 10})
          .height('100%')
          .zIndex(1)

          if (this.originImgUrl) {
            Stack() {
              this.Mask()
              Image(this.originImgUrl)// 直接加载网络地址，请填写一个具体的网络图片地址
                // .alt($r('media.LoadingProgress'))// 使用alt，在网络图片加载成功前使用占位图
                .width("100%")
                .height("100%")
                .objectFit(ImageFit.ScaleDown)
                .zIndex(2)
                .onClick((e)=>{
                  this.originImgUrl = ""
                })
            }.zIndex(2)
          }
        }

      }.width('100%').height('100%')

    }
  }
}