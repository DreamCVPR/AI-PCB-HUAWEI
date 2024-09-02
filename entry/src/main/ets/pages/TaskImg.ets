import router from '@ohos.router';
import { baseUrl } from '../utils/request'
import { getTaskImg } from '../api/taskImg'
import { CommonConstants } from '../common/classes';
import { SwiperDataSource } from '../utils/SwiperDataSource'

@Entry
@Component
export struct TaskImg {
  @State message: string = '检测页';
  @State task: object = (router.getParams() as object);
  @State taskId: number = (router.getParams() as object)['taskId'];
  @State taskImgList: Array<object> = [];
  @State originImgIndex: number = -1;
  @State originImgTranslate: Array<object> = [];
  @State originImgScale: Array<object> = [];
  @State originImgSize: Array<object> = [];
  @State chooseImgIndex?: Array<number> = undefined
  @State isImgEdge: boolean = true
  @State maskType: HitTestMode = HitTestMode.None;
  @StorageLink("token") token: object | null = null;



  settings: RenderingContextSettings = new RenderingContextSettings(true)
  context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  img?: ImageBitmap
  originImgSwiperController: SwiperController = new SwiperController()



  // @State taskImg: JSON;

  aboutToAppear(): void {
    if (!this.token)
      router.replaceUrl({url: 'pages/Login'})
    this.getTaskImg()
  }

  getTaskImg() {
    getTaskImg({'taskId': this.taskId})
      .then((res: object) => {
        this.taskImgList = res['result']
        this.originImgSize = Array.from(this.taskImgList.keys()).map(v=>new Object())
        this.resetOriginImg()
        console.log("获取taskImg成功:"+  JSON.stringify(res));
      })
      .catch((err: object) => {
        console.log("获取taskImg失败:" + JSON.stringify(err))
      })
  }

  resetOriginImg(originImgIndex: number = -1) {
    this.originImgTranslate = Array.from(this.taskImgList.keys()).map(v=>new Object({
      "offsetX": 0,
      "offsetY": 0,
      "positionX": 0,
      "positionY": 0,
    }))
    this.originImgScale = Array.from(this.taskImgList.keys()).map(v=>new Object({
      "scaleValue": 1,
      "pinchValue": 1,
      "pinchX": 0,
      "pinchY": 0,
    }))
    this.originImgSize = this.originImgSize.map(v=>{
      if (v['originSize']) {
        v['nowSize'] = v['originSize']
      }
      return v
    })
    this.originImgIndex = originImgIndex
  }

  judgeImgEdge(originSize: object, nowSize: object, offset: object) {
    // 左右边缘
    if ((nowSize["width"]-originSize["width"])/2 - Math.abs(offset["offsetX"]) < 0) {
      this.isImgEdge = false
    }
    // 上下边缘
    else if ((nowSize["height"]-originSize["height"])/2 - Math.abs(offset["offsetY"]) < 0) {
      this.isImgEdge = false
    }
    else this.isImgEdge = true
    if (this.isImgEdge) {
      this.maskType = HitTestMode.Block
    } else this.maskType = HitTestMode.None
    return this.isImgEdge
  }

  @Builder Mask(opacity: number = 0.95, zIndex: number = 1) {
    Row() {}.height("100%").width("100%").backgroundColor(Color.Gray).opacity(opacity).zIndex(zIndex)
  }

  @Builder ImgCard(img: object, index: number) {
    Column() {
      Stack() {
        // 低清图片
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
          Text((index+1).toString().padStart(2, '0'))
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
          this.img = new ImageBitmap(baseUrl+"/file/download/"+img["imgUrl"])
          this.originImgIndex = index
        })
        .gesture(
          LongPressGesture({fingers: 1, repeat: false, duration: 300})
            .onAction(event=>{
              this.chooseImgIndex = [index]
            })
        )
        // 选择图片
        if (this.chooseImgIndex !== undefined) {
          Row() {
            this.Mask(0.5)
          }
          .onClick(()=>{
            if (this.chooseImgIndex !== undefined) {
              if (this.chooseImgIndex.includes(index)) {
                this.chooseImgIndex = this.chooseImgIndex.filter(item => item != index)
              } else {
                this.chooseImgIndex?.push(index)
              }
            }
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
      this.ImgCard(taskImgList[index], index)
      if (index+1 < taskImgList.length) {
        this.ImgCard(taskImgList[index+1], index+1)
      }
    }
    .width('100%')
    .padding({bottom: '2%'})
    .aspectRatio(2)
  }

  @Builder OriginImg(img: object, index: number) {
    Stack() {
      this.Mask()
      // Canvas(this.context)
      //   .width('100%')
      //   .height('100%')
      //   .onReady(() =>{
      //     this.context.drawImage(this.img,0,0, 130, 130)
      //     let img = this.context.getImageData(50, 50, 130, 130)
      //     this.context.putImageData(img, 150, 150)
      //   })
      //   .zIndex(2)
      Image(baseUrl+"/file/download/"+img["imgUrl"])
        .alt($r('app.media.load_img'))
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.ScaleDown)
        .zIndex(2)
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          if (!this.originImgSize[index]['originSize']) {
            this.originImgSize[index] = new Object({
              "originSize": newValue,
              "nowSize": newValue
            })
          }
        })
        .scale({ x: this.originImgScale[index]["scaleValue"], y: this.originImgScale[index]["scaleValue"], z: 1 })
        .translate({ x: this.originImgTranslate[index]["offsetX"], y: this.originImgTranslate[index]["offsetY"], z: 0 })
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            // 在组件上绑定2指触发的捏合手势
            PinchGesture({ fingers: 2 })
              .onActionStart((event: GestureEvent) => {
                console.info('Pinch start');
              })
                // 当捏合手势触发时，可以通过回调函数获取缩放比例，从而修改组件的缩放比例
              .onActionUpdate((event: GestureEvent) => {
                this.originImgScale[index]["scaleValue"] = this.originImgScale[index]["pinchValue"] * event.scale;
                this.originImgScale[index]["pinchX"] = event.pinchCenterX;
                this.originImgScale[index]["pinchY"] = event.pinchCenterY;
                if (this.originImgScale[index]["scaleValue"] < 0.9) {
                  this.originImgScale[index]["scaleValue"] = 0.9
                }
                this.originImgScale = JSON.parse(JSON.stringify(this.originImgScale))
              })
              .onActionEnd(() => {
                this.originImgScale[index]["pinchValue"] = this.originImgScale[index]["scaleValue"];
                if (this.originImgScale[index]["scaleValue"] < 1) {
                  this.resetOriginImg(index)
                }
                const originSize: object = this.originImgSize[index]['originSize']
                this.originImgSize[index]['nowSize'] = {
                  "width": originSize["width"]*this.originImgScale[index]["scaleValue"],
                  "height": originSize["height"]*this.originImgScale[index]["scaleValue"]
                }
                this.originImgScale = JSON.parse(JSON.stringify(this.originImgScale))
                console.info('Pinch end');
              }),
            // 拖动
            PanGesture()
              .onActionStart((event: GestureEvent|undefined) => {
                console.info('Pan start');
              })
                // 当触发拖动手势时，根据回调函数修改组件的布局位置信息
              .onActionUpdate((event: GestureEvent|undefined) => {
                if(event){
                  const offsetX: number = this.originImgTranslate[index]["positionX"] + event.offsetX*this.originImgScale[index]["scaleValue"]
                  const offsetY: number = this.originImgTranslate[index]["positionY"] + event.offsetY*this.originImgScale[index]["scaleValue"]
                  if (!this.originImgSize[index]['originSize'] || !this.judgeImgEdge(this.originImgSize[index]['originSize'], this.originImgSize[index]['nowSize'], new Object({'offsetX': offsetX, 'offsetY': offsetY}))) {
                    if (event.offsetX < -15) {
                      this.originImgSwiperController.changeIndex(index+1, true)
                    } else if (event.offsetX > 15) {
                      this.originImgSwiperController.changeIndex(index-1, true)
                    }
                    return
                  }
                  this.originImgTranslate[index]["offsetX"] = offsetX
                  this.originImgTranslate[index]["offsetY"] = offsetY
                  this.originImgTranslate = JSON.parse(JSON.stringify(this.originImgTranslate))
                }
              })
              .onActionEnd(() => {
                const offsetX: number = this.originImgTranslate[index]["offsetX"]
                const offsetY: number = this.originImgTranslate[index]["offsetY"]
                if (!this.originImgSize[index]['originSize'] || !this.judgeImgEdge(this.originImgSize[index]['originSize'], this.originImgSize[index]['nowSize'], new Object({'offsetX': offsetX, 'offsetY': offsetY}))) {
                  return
                }
                this.originImgTranslate[index]["positionX"] = offsetX
                this.originImgTranslate[index]["positionY"] = offsetY
                this.originImgTranslate = JSON.parse(JSON.stringify(this.originImgTranslate))
              })
          )
        )
    }
    .zIndex(2)
    .onClick((e)=>{
      console.log("this.originImgIndex："+ this.originImgIndex)
      this.resetOriginImg()
    })
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // 顶部导航栏
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
                      this.chooseImgIndex = Array.from(this.taskImgList.keys())
                    }
                  }
                })
            }
          }
        }
        .width('100%')
        .height(AppStorage.get('statusBarHeight') as number - 10)
        .backgroundColor('rgb(130, 178, 154)')
        .padding({
          left: 10,
          right: 10,
          top: 30,
          bottom: 0
        })
        // 图片列表
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

          // 图片详情
          if (this.originImgIndex > -1) {
            Text((this.originImgIndex+1)?.toString()+'/'+this.taskImgList.length.toString())
              .fontSize(15)
              .backgroundColor("#616163")
              .position({top: "2%", left: "2%"})
              .fontColor("#C9C9CB")
              .zIndex(3)
              .padding(5)
            Swiper(this.originImgSwiperController) {
              LazyForEach(new SwiperDataSource(this.taskImgList), (img: object, index: number) => {
                this.OriginImg(img, index)
              }, (item: string) => item)
            }
            .onChange((index: number) => {
              this.resetOriginImg(index)
            })
            .effectMode(EdgeEffect.Fade)
            .hitTestBehavior(HitTestMode.None)
            .width("100%")
            .height("100%")
            .cachedCount(2)
            .index(this.originImgIndex)
            .duration(100)
            .itemSpace(0)
            .loop(false)
            .zIndex(2)
          }
        }
      }.width('100%').height('100%')
    }
  }
}