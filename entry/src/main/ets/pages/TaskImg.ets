import router from '@ohos.router';
import {baseUrl} from '../utils/request'
import { getTaskImg } from '../api/taskImg'
import { CommonConstants } from '../common/classes';

@Entry
@Component
export struct TaskImg {
  @State message: string = '检测页';
  @State task: object = (router.getParams() as object);
  @State taskId: number = (router.getParams() as object)['taskId'];
  @State taskImgList: Array<object> = []
  @State originImgUrl: string = ""
  @State chooseImgIndex?: Array<number> = undefined

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

  @Builder Mask(opacity: number = 0.95, zIndex: number = 1) {
    Row() {}.height("100%").width("100%").backgroundColor(Color.Gray).opacity(opacity).zIndex(zIndex)
  }

  @Builder ImgCard(img: object, index: number) {
    Column() {
      Stack() {
        Row() {
          Image(baseUrl+"/file/compress/"+img["imgUrl"])
            .alt($r('app.media.load_img'))
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
        .onClick((e)=>{
          this.originImgUrl = baseUrl+"/file/download/"+img["imgUrl"]
        })
        .gesture(
          LongPressGesture({fingers: 1, repeat: false, duration: 300})
            .onAction(event=>{
              this.chooseImgIndex = [index]
            })
        )
        if (this.chooseImgIndex !== undefined) {
          Row() {
            this.Mask(0.7)
          }
          .onClick(()=>{
            if (this.chooseImgIndex !== undefined) {
              if (this.chooseImgIndex.includes(index)) {
                this.chooseImgIndex = this.chooseImgIndex.filter(item => item != index)
              } else {
                this.chooseImgIndex?.push(index)
              }
            }
            console.log('this.chooseImgIndex: '+ this.chooseImgIndex)
          })
          Checkbox()
            .select(this.chooseImgIndex.includes(index))
            .selectedColor(0x39a2db)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onClick(() => {
              if (this.chooseImgIndex !== undefined) {
                if (this.chooseImgIndex.includes(index)) {
                  this.chooseImgIndex = this.chooseImgIndex.filter(item => item != index)
                } else {
                  this.chooseImgIndex?.push(index)
                }
              }
              console.log('this.chooseImgIndex: '+ this.chooseImgIndex)
            })
            .zIndex(2)
            .position({top: 2, right: 2})
            .borderColor(Color.White)
        }
      }
    }
    .width('49%')
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
          Flex() {
            Image($r('app.media.left_arrow'))
              .height(25)
              .width(25)
              .margin({ left: 2 })
              .onClick(()=>{
                if (this.chooseImgIndex == undefined) {
                  router.back()
                } else {
                  this.chooseImgIndex = undefined
                }
              })
            Text(this.chooseImgIndex == undefined ? this.task['taskName'] : '已选'+this.chooseImgIndex?.length.toString()+'项')
              .fontColor(Color.White)
              .fontSize(20)
              .fontWeight(700)
              .textAlign(TextAlign.Start)
              .margin({ left: 10 })
            Blank()
            if (this.chooseImgIndex !== undefined) {
              Text(this.chooseImgIndex.length == this.taskImgList.length ? '取消全选' : '全选')
                .fontColor(Color.White)
                .fontSize(20)
                .fontWeight(700)
                .textAlign(TextAlign.Start)
                .margin({ right: 4 })
                .onClick(()=>{
                  if (this.chooseImgIndex !== undefined) {
                    if (this.chooseImgIndex.length == this.taskImgList.length) {
                      this.chooseImgIndex = []
                    } else {
                      this.chooseImgIndex = Array.from(this.taskImgList.keys()).map(v=>v+1)
                    }
                  }
                })
            }
          }
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
                .alt($r('app.media.load_img'))
                .width("100%")
                .height("100%")
                .objectFit(ImageFit.ScaleDown)
                .zIndex(2)
                .onClick((e)=>{
                  console.log("this.originImgUrl："+ this.originImgUrl)
                  this.originImgUrl = ""
                })
            }.zIndex(2)
          }
        }

      }.width('100%').height('100%')
    }
  }
}