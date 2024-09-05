import router from '@ohos.router';
import { baseUrl } from '../utils/request'
import { addImg, detect, getTaskImg, removeImg } from '../api/taskImg'
import { SwiperDataSource } from '../utils/SwiperDataSource'
import { Empty } from '../components/Empty';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { FileUtils } from '../utils/FileUtils';
import { InteractionUtils } from '../utils/InteractionUtils';
import { Loading } from '../components/Loading';
import { cateFlowMap, colorFlowMap, ThemeColor } from '../common/settings';

import { BusinessError } from '@kit.BasicServicesKit';

import image from '@ohos.multimedia.image';
import { componentSnapshot } from '@kit.ArkUI';
@Entry
@Component
struct TaskImg {
  @StorageLink("token") token: object | null = null;

  COMPRESS_FILE: string = FileUtils.COMPRESS_FILE
  ORIGIN_FILE: string = FileUtils.ORIGIN_FILE
  CLASS_CN_NAME: object = cateFlowMap
  LABEL_COLOR: object = colorFlowMap

  @State task: object = (router.getParams() as object);
  @State taskId: number = (router.getParams() as object)['taskId'];
  @State taskImgList: Array<object> = [];
  @State chooseImgIndex?: Array<number> = undefined
  @State originImgIndex: number = -1;
  @State originImgTranslate: Array<object> = [];
  @State originImgScale: Array<object> = [];
  @State originImgSize: Array<object> = [];
  @State originImgRealSize: Array<object> = [];
  @State showLoading: boolean = true;
  @State showImgDefect: boolean = true;
  @State showImgDefectClassName: object = new Object({
    "mouse_bite": true,
    "short": true,
    "spur": true,
    "spurious_copper": true,
    "open_circuit": true
  })
  @State isImgEdge: boolean = true
  @State isRefreshing: boolean = false;

  private originImgSwiperController: SwiperController = new SwiperController()

  aboutToAppear(): void {
    this.getTaskImg().then(()=>this.originImgRealSize = Array.from(this.taskImgList.keys()).map(v=>new Object()))
  }

  getTaskImg() {
    return getTaskImg({'taskId': this.taskId})
      .then((res: object) => {
        this.taskImgList = res['result']
        this.taskImgList.map((item: object, index: number) => {
          if (item["detectionClasses"]) {
            item["detectionClasses"] = JSON.parse(item["detectionClasses"])
            item["detectionBoxes"] = JSON.parse(item["detectionBoxes"])
            item["detectionScores"] = JSON.parse(item["detectionScores"])
          }
          return item
        });
        this.originImgSize = Array.from(this.taskImgList.keys()).map(v=>new Object())
        this.isRefreshing = false
        this.resetOriginImg()
        this.showLoading = false
        console.log("获取taskImg成功:"+  JSON.stringify(res));
      })
      .catch((err: object) => {
        this.showLoading = false
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
    return this.isImgEdge
  }

  copyText(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    systemPasteboard.getData().then((data) => {
      if (data) {
        promptAction.showToast({ message: '复制链接成功' });
      } else {
        promptAction.showToast({ message: '复制链接失败' });
      }
    })
  }

  save2Album() {
    if (this.chooseImgIndex !== undefined) {
      FileUtils.saveImg(this.chooseImgIndex.map(index=>{
        return baseUrl+this.ORIGIN_FILE+this.taskImgList[index]["imgUrl"]
      }))
      this.chooseImgIndex = undefined
    }
  }

  move2OtherTask() {}

  remove() {
    if (this.chooseImgIndex !== undefined) {
      this.showLoading = true
      InteractionUtils.confirm(
        `是否删除${this.chooseImgIndex.length}张图片？`,
        '删除后3天内可在“我的”回收站中找回，请确认是否删除',
        ()=>{
          removeImg({'imgIds': this.taskImgList.filter((v: object, index: number)=>this.chooseImgIndex?.includes(index)).map((value: object): number=>value["imgId"]).join(',')})
            .then((res: object) => {
              this.chooseImgIndex = undefined
              router.replaceUrl({
                "url": "pages/TaskImg",
                "params": this.task
              })
              console.log("删除taskImg成功:"+  JSON.stringify(res));
            })
            .catch((err: object) => {
              this.showLoading = false
              this.chooseImgIndex = undefined
              console.log("删除taskImg失败:" + JSON.stringify(err))
            })
        },
        ()=>this.showLoading = false
      )
    }
  }

  add() {
    this.showLoading = true
    FileUtils.chooseImage().then(imgList=>{
      if (imgList[0].length > 0) {
        addImg({'taskId': this.taskId, "files": imgList[0], "fileNames": imgList[1]})
          .then((res: object) => {
            this.getTaskImg().then(()=>this.originImgRealSize = Array.from(this.taskImgList.keys()).map(v=>new Object()))
            console.log("增加taskImg成功:"+  JSON.stringify(res));
          })
          .catch((err: object) => {
            this.showLoading = false
            console.log("增加taskImg失败:" + JSON.stringify(err))
          })
      } else {
        this.showLoading = false
      }
    })
  }

  detect() {
    let img2Detect: object[] = []
    if (this.chooseImgIndex == undefined) {
      img2Detect = this.taskImgList.filter(item => item["isDetect"] == 0)
    } else {
      img2Detect = this.taskImgList.filter((item, index) => item["isDetect"] == 0 && this.chooseImgIndex?.includes(index))
    }

    if (img2Detect.length == 0) {
      promptAction.showToast({ message: '当前没有未检测的图片' });
    } else {
      InteractionUtils.confirm(
        `开始检测${img2Detect.length}张图片`,
        '已检测的图片不再检测',
        ()=>{
          this.task['taskState'] = 2
          this.chooseImgIndex = undefined
          detect(img2Detect)
            .then((res: object) => {
              this.getTaskImg().then(()=>{
                this.task['taskState'] = 0
              })
              console.log("检测成功");
            })
            .catch((err: object) => {
              this.task['taskState'] = 0
              console.log("增加taskImg失败:" + JSON.stringify(err))
            })
        },
        ()=>{},
        200
      )
    }
  }

  getScale(index: number) {
    // 计算图片缩放因子
    const realSize: object = this.originImgRealSize[index]
    const componentSize: object = this.originImgSize[index]["originSize"]
    return Math.min(componentSize["width"] / realSize["width"], componentSize["height"] / realSize["height"])
  }

  getImgOriginPos(index: number) {
    // 计算图片在图片组件中渲染的位置
    const realSize: object = this.originImgRealSize[index]
    const componentSize: object = this.originImgSize[index]["originSize"]
    const scale: number = Math.min(componentSize["width"] / realSize["width"], componentSize["height"] / realSize["height"])
    const nowRealSize: object = new Object({"height": realSize["height"]*scale, "width": realSize["width"]*scale})
    const componentCenterPos: object = new Object({"x": componentSize["width"]/2, "y": componentSize["height"]/2})
    return new Object({"left": componentCenterPos["x"]-nowRealSize["width"]/2, "top": componentCenterPos["y"]-nowRealSize["height"]/2})
  }

  getImgLabelPos(originPos: object, offsetX: number, offsetY: number, scale: number, units: string = "vp") {
    return new Object({"left": `${originPos["left"]+offsetX*scale}${units}`, "top": `${originPos["top"]+offsetY*scale}${units}`})
  }

  @Builder Mask(opacity: number = 0.95, zIndex: number = 1) {
    Row() {}.height("100%").width("100%").backgroundColor(Color.Gray).opacity(opacity).zIndex(zIndex)
  }

  @Builder ImgCard(img: object, index: number) {
    Column() {
      Stack() {
        // 低清图片
        Row() {
          Image(baseUrl+this.COMPRESS_FILE+img["imgUrl"])
            .alt($r('app.media.load_img'))
            .width("100%")
            .height("100%")
            .objectFit(ImageFit.CENTER)
            .onComplete((event) => {
              if (event) {
                this.originImgRealSize[index] = new Object({
                  "height": event.height,
                  "width": event.width
                })
              }
            })
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
          if (this.taskImgList[index]["isDetect"]) {
            Image($r('app.media.yes'))
              .height(15)
              .width(15)
              .position({bottom: 1, right: 3})
          }
        }
        .onClick((e)=>{
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
            .selectedColor(ThemeColor.CheckBoxSelectColor)
            .unselectedColor(ThemeColor.CheckBoxUnSelectedColor)
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
      Row() {
        Image(baseUrl+this.ORIGIN_FILE+img["imgUrl"])
          .alt($r('app.media.load_img'))
          .width("100%")
          .height("100%")
          .objectFit(ImageFit.ScaleDown)
        this.Label(index)
      }
      .width("100%")
      .height("100%")
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
                  if (Math.abs(event.offsetY) < 2) {
                    if (event.offsetX < -12) {
                      this.originImgSwiperController.changeIndex((index+1)%this.taskImgList.length, true)
                    } else if (event.offsetX > 12) {
                      this.originImgSwiperController.changeIndex((index+this.taskImgList.length-1)%this.taskImgList.length, true)
                    }
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

  @Builder Tab(img: ResourceStr, test: string) {
    Column() {
      Image(img)
        .width(25)
        .height(25)
        .objectFit(ImageFit.Contain)
      Text(test)
        .fontSize(11)
        .fontWeight(400)
        .lineHeight(14)
    }.width('100%')
  }

  @Builder Background(color: ResourceColor, opacity: number) {
    Row() {}.backgroundColor(color).opacity(opacity).width("100%").height("100%")
  }

  @Builder LabelClass(className: string) {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Circle()
        .width(15)
        .height(15)
        .fill(this.LABEL_COLOR[className])
        .fillOpacity(0.5)
        .strokeWidth(1)
        .stroke(this.LABEL_COLOR[className])
      Text(this.CLASS_CN_NAME[className])
        .fontSize(11)
        .fontWeight(400)
        .lineHeight(15)
        .margin({left: 10})
    }
    .width("100%")
    .height(30)
    .background(this.Background(this.LABEL_COLOR[className], 0.3))
    .opacity(this.showImgDefectClassName[className] ? 1 : 0.4)
    .shadow({radius: 1, color: this.LABEL_COLOR[className]})
    .onClick(()=>{
      this.showImgDefectClassName[className] = !this.showImgDefectClassName[className]
    })
  }

  @Builder Label(imgIndex: number, scale: number | undefined = undefined, originPos: object | undefined = undefined, units: string = "vp") {
    if (this.taskImgList[imgIndex]["isDetect"] == 1) {
      if (this.originImgSize[imgIndex]['originSize']) {
        ForEach(this.taskImgList[imgIndex]["detectionClasses"], (className: string, index: number) => {
          Text(this.taskImgList[imgIndex]["detectionScores"][index].toFixed(2))
            .fontSize(`${12 * (scale ? scale : this.getScale(imgIndex))}${units}`)
            .fontColor(Color.Black)
            .position(this.getImgLabelPos(
              originPos ? originPos : this.getImgOriginPos(imgIndex),
              this.taskImgList[imgIndex]["detectionBoxes"][index][1],
              this.taskImgList[imgIndex]["detectionBoxes"][index][0] < 14 ? this.taskImgList[imgIndex]["detectionBoxes"][index][2]-this.taskImgList[imgIndex]["detectionBoxes"][index][0]+2 : this.taskImgList[imgIndex]["detectionBoxes"][index][0]-14,
              scale ? scale : this.getScale(imgIndex), units))
            .visibility(this.showImgDefect && this.showImgDefectClassName[className] ? Visibility.Visible : Visibility.Hidden)
          Rect()
            .width(`${(this.taskImgList[imgIndex]["detectionBoxes"][index][3]-this.taskImgList[imgIndex]["detectionBoxes"][index][1])*(scale ? scale : this.getScale(imgIndex))}${units}`)
            .height(`${(this.taskImgList[imgIndex]["detectionBoxes"][index][2]-this.taskImgList[imgIndex]["detectionBoxes"][index][0])*(scale ? scale : this.getScale(imgIndex))}${units}`)
            .position(this.getImgLabelPos(
              originPos ? originPos : this.getImgOriginPos(imgIndex),
              this.taskImgList[imgIndex]["detectionBoxes"][index][1],
              this.taskImgList[imgIndex]["detectionBoxes"][index][0],
              scale ? scale : this.getScale(imgIndex), units))
            .zIndex(4)
            .fill(this.LABEL_COLOR[className])
            .fillOpacity(0.3)
            .stroke(this.LABEL_COLOR[className])
            .strokeWidth(0.1)
            .visibility(this.showImgDefect && this.showImgDefectClassName[className] ? Visibility.Visible : Visibility.Hidden)
        })
      }
    }
  }

  @Builder AddImg() {
    if (this.chooseImgIndex == undefined && this.originImgIndex == -1 && this.task['taskState'] == 0) {
      Image($r('app.media.upload'))
        .width(36)
        .height(36)
        .borderRadius("50%")
        .objectFit(ImageFit.None)
        .position({"right": 37, "bottom": 130})
        .backgroundColor(Color.White)
        .shadow(ThemeColor.Shadow)
        .zIndex(10)
        .onClick(()=>{
          this.add()
        })
    }
  }

  @Builder Detect() {
    if (this.chooseImgIndex == undefined && this.originImgIndex == -1 && this.task['taskState'] == 0) {
      Image($r('app.media.detect'))
        .width(60)
        .height(60)
        .borderRadius("50%")
        .objectFit(ImageFit.None)
        .position({"right": 25, "bottom": 50})
        .backgroundColor("#F5AEB3")
        .shadow(ThemeColor.Shadow)
        .zIndex(10)
        .onClick(()=>{
          this.detect()
        })
    }
  }

  @Builder DrawOriginImg(index: number) {
    Row() {
      Image(baseUrl+this.ORIGIN_FILE+this.taskImgList[index]["imgUrl"])
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.ScaleDown)
      this.Label(index, 1, new Object({"top": 0, "left": 0}), "px")
    }
    .width(`${this.originImgRealSize[index]["width"]}px`)
    .height(`${this.originImgRealSize[index]["height"]}px`)
  }

  @Builder TopBar() {
    Row() {
      Flex() {
        Image($r('app.media.left_arrow'))
          .height(25)
          .width(25)
          .margin({ left: 2 })
          .position({bottom: -1})
          .fillColor(ThemeColor.FontColor)
          .onClick(()=>{
            if (this.chooseImgIndex == undefined) {
              if (this.originImgIndex == -1) {
                router.back({
                  url: "",
                  params: { "refresh": true }
                })
              } else {
                this.resetOriginImg()
              }
            } else {
              this.chooseImgIndex = undefined
            }
          })
        Text(this.originImgIndex > -1 ? (this.originImgIndex+1).toString().padStart(2, '0') : (this.chooseImgIndex == undefined ? this.task['taskName'] : '已选'+this.chooseImgIndex?.length.toString()+'项'))
          .fontColor(ThemeColor.FontColor)
          .textShadow(ThemeColor.TextShadow)
          .fontSize(20)
          .fontWeight(400)
          .textAlign(TextAlign.Start)
          .margin({ left: 10+27 })
        Blank()
        if (this.chooseImgIndex !== undefined) {
          Text(this.chooseImgIndex.length == this.taskImgList.length ? '取消全选' : '全选')
            .fontColor(ThemeColor.FontColor)
            .textShadow(ThemeColor.TextShadow)
            .fontSize(20)
            .fontWeight(400)
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
        } else if (this.originImgIndex > -1) {
          Image($r('app.media.screenshot'))
            .height(25)
            .width(25)
            .margin({ right: 10 })
            .fillColor(ThemeColor.FontColor)
            .onClick(()=>{
              componentSnapshot.createFromBuilder(()=>{this.DrawOriginImg(this.originImgIndex)}, 320, true, {scale : 1, waitUntilRenderFinished : true})
                .then((pixelMap: image.PixelMap) => {
                  FileUtils.savePixelMap(pixelMap)
                })
                .catch((err: BusinessError) => {
                  console.error(`Failed to pack the image.Code ${err.code},message is ${err.message}`);
                })
                .catch((err:Error) => {
                  console.log("error: " + err)
                })
            })
          Image($r('app.media.share'))
            .height(25)
            .width(25)
            .margin({ right: 10 })
            .fillColor(ThemeColor.FontColor)
            .onClick(()=>{
              this.copyText(baseUrl+this.ORIGIN_FILE+this.taskImgList[this.originImgIndex]['imgUrl'])
            })
          Image(this.showImgDefect && this.taskImgList[this.originImgIndex]["isDetect"] == 1 ? $r('app.media.open_eye') : $r('app.media.close_eye'))
            .height(25)
            .width(25)
            .fillColor(ThemeColor.FontColor)
            .margin({ right: 4 })
            .onClick(()=>{
              if (this.taskImgList[this.originImgIndex]["isDetect"] !== 1) {
                promptAction.showToast({ message: '当前图片未经检测，无法查看瑕疵' });
              } else {
                this.showImgDefect = !this.showImgDefect
              }
            })
        }
      }
    }
    .width('100%')
    .height(AppStorage.get('statusBarHeight') as number - 30)
    .backgroundColor(ThemeColor.ThemeColor)
    .padding({
      left: 10,
      right: 10,
      top: 30,
      bottom: 0
    })
  }

  @Builder ImgList() {
    this.AddImg()
    this.Detect()
    Refresh({ refreshing: $$this.isRefreshing}) {
      Row() {
        Empty().visibility(this.taskImgList.length == 0 && !this.showLoading ? Visibility.Visible : Visibility.None)
        List({ initialIndex: 0 }) {
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
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Fade)
      }.width("100%").height("100%")
    }
    .onRefreshing(() => {
      this.getTaskImg()
    })
    .height("100%")
    .width("100%")
    .backgroundColor(ThemeColor.BackgroundColor)
    .refreshOffset(64)
    .pullToRefresh(this.chooseImgIndex == undefined)
    .pullDownRatio(this.chooseImgIndex == undefined ? 1 : 0)
  }

  @Builder ImgInfo() {
    if (this.originImgIndex > -1) {
      // 左上角图片索引
      Text((this.originImgIndex+1)?.toString()+'/'+this.taskImgList.length.toString())
        .fontSize(15)
        .backgroundColor("#616163")
        .position({top: "2%", left: "2%"})
        .fontColor("#C9C9CB")
        .zIndex(3)
        .padding(5)
      // 底部标签类别
      GridRow({columns: 5}) {
        ForEach(Object.keys(this.CLASS_CN_NAME), (key: string, index: number)=>{
          GridCol() {
            this.LabelClass(key)
          }
        })
      }
      .width("100%")
      .backgroundColor('rgba(0, 0, 0, 0)')
      .position({bottom: 22})
      .zIndex(3)
      .visibility(this.showImgDefect && this.taskImgList[this.originImgIndex]["isDetect"] == 1 ? Visibility.Visible : Visibility.Hidden)
      // 原图
      Swiper(this.originImgSwiperController) {
        LazyForEach(new SwiperDataSource(this.taskImgList), (img: object, index: number) => {
          this.OriginImg(img, index)
        }, (item: string) => item)
      }
      .onChange((index: number) => {
        this.resetOriginImg(index)
      })
      .hitTestBehavior(HitTestMode.None)
      .width("100%")
      .height("100%")
      .cachedCount(2)
      .index(this.originImgIndex)
      .duration(100)
      .itemSpace(0)
      .loop(true)
      .zIndex(2)
    }
  }

  @Builder BottomBar() {
    if (this.chooseImgIndex !== undefined) {
      Stack({alignContent: Alignment.Center}) {
        GridRow({columns: 5}) {
          GridCol() { this.Tab($r('app.media.share'), '分享') }
          .onClick(()=>{
            let text: Array<string> = []
            if (this.chooseImgIndex !== undefined) {
              this.chooseImgIndex.forEach(index => {
                text.push(baseUrl+ this.ORIGIN_FILE+this.taskImgList[index]['imgUrl'])
              });
            }
            this.copyText(text.join('\n'))
          })
          GridCol() { this.Tab($r('app.media.download'), '保存到相册') }
          .onClick(()=>{
            this.save2Album()
          })
          GridCol() {}
          GridCol() { this.Tab($r('app.media.move'), '移动') }
          .onClick(()=>{
            router.pushUrl({
              "url": "pages/TaskList",
              "params": new Object({
                "taskId": this.taskId,
                "imgIds": this.taskImgList.filter((v, i)=>this.chooseImgIndex?.includes(i)).map((v: object): string=>v["imgId"]).join(",")
              })
            })
          })
          GridCol() { this.Tab($r('app.media.remove'), '删除') }
          .onClick(()=>{
            this.remove()
          })
        }
        .width('100%')
        .height(56)
        .margin({bottom: 5})
        Image($r('app.media.detect'))
          .width(60)
          .height(60)
          .borderRadius("50%")
          .objectFit(ImageFit.None)
          .margin({bottom: 46})
          .backgroundColor("#F5AEB3")
          .onClick(()=>{
            this.detect()
          })
      }
      .enabled(this.chooseImgIndex.length > 0)
      .opacity(this.chooseImgIndex.length > 0 ? 1 : 0.7)
      .height(80)
      .backgroundColor(Color.White)
    }
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // 顶部导航栏
        this.TopBar()
        Flex({ direction: FlexDirection.Column }) {
          Loading({ show: this.showLoading })
          Stack() {
            // 图片列表
            this.ImgList()
            // 图片详情
            this.ImgInfo()
          }
          .backgroundColor(ThemeColor.BackgroundColor)
          // 底部导航栏
          this.BottomBar()
        }.width('100%').height('100%')
      }.width('100%').height('100%')
    }.width('100%').height('100%')
  }
}