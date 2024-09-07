import router from '@ohos.router';
import { Response, TaskElem } from '../common/classes'
import { delTask, getTasks, startDet } from '../api/service'
import { TaskController } from '../controllers/TaskController';
import { Empty } from '../components/Empty';
import { Loading } from '../components/Loading';
import { cateFlowMap, noticeTime, requestTime, colorFlowMap, ThemeColor, DisableBackground } from '../common/settings';
import { Notice } from '../components/Notice';
import { NoticeController } from '../controllers/NoticeController';
import { Background } from '../builder/Background';


@Component
export struct Task {
  @Link openBatchDel: boolean;
  @Link chooseTaskIdx: Array<number>;
  @Link taskList: Array<TaskElem>;

  @State showLoading: boolean = false;
  @State message: string = '任务列表';
  @State isRefreshing: boolean = false;
  @State selectedId: number = -1;

  @StorageLink("token") token: string = '';

  private noticeController: NoticeController = new NoticeController()
  public taskController: TaskController | null = null;

  // 生命钩子函数
  aboutToAppear(){
    if (this.token === '')
      router.replaceUrl({url: 'pages/Login'})
    if (this.taskController) {
      this.taskController.attach(this); //绑定控制器
    }
    this.getTasks();
  }


  showDelDialog(index: number) {
    AlertDialog.show(
      {
        title: `已选择1项任务，是否删除?`,
        message: '删除后3天内可在”我的“回收站中找回，请确认是否删除',
        autoCancel: true,
        alignment: DialogAlignment.Center,
        gridCount: 4,
        offset: { dx: 0, dy: -20 },
        primaryButton: {
          value: '取消',
          fontColor: '#000000',
          backgroundColor: '#ffffff',
          action: () => {
            this.selectedId = -1;
          }
        },
        secondaryButton: {
          value: '确定',
          fontColor: '#000000',
          backgroundColor: '#ffffff',
          action: () => {
            delTask({
              taskIds: this.taskList[index].taskId
            }, `已删除1项任务`)
              .then((res: Response) => {
                if (res.status == 200) {
                  setTimeout(() => {
                    this.getTasks();
                  }, requestTime)
                }
              })
              .catch((err: Response) => {
              })
          }
        },
        cancel: () => {
          this.selectedId = -1;
        }
      }
    )
  }

  @Builder itemEnd(index: number) {
    Row() {
      Image($r('app.media.delete4'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.showDelDialog(index);
        })
    }
    .margin({right: 10, left: 10})
  }

  // 任务单项
  @Builder TaskItem(item: TaskElem, index: number) {
      ListItem() {
          Row() {
            Badge({
              count: item?.countDefect,
              position: {x: 0, y: -20},
              style: { badgeSize: 20, badgeColor: '#FA2A2D' }
            })
            {
              Flex({ alignItems: ItemAlign.Center }) {
                if (this.openBatchDel) {
                  Checkbox()
                    .select(this.chooseTaskIdx.includes(item.taskId))
                    .selectedColor(ThemeColor.CheckBoxSelectColor)
                    .unselectedColor(ThemeColor.CheckBoxUnSelectedColor)
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .onClick(() => {
                      if (this.chooseTaskIdx.includes(item.taskId)) {
                        this.chooseTaskIdx = this.chooseTaskIdx.filter((i: number) => i != item.taskId)
                      } else {
                        this.chooseTaskIdx.push(item.taskId)
                      }
                      console.log('this.chooseTaskIdx: ' + this.chooseTaskIdx)
                    })
                    .position({ top: -12, right: 4 })
                    .borderColor(Color.White)
                    .zIndex(999)
                }
                Row() {
                  Column() {
                    Text(item.taskName)
                      .fontColor(ThemeColor.FontColor)
                      .margin({ bottom: 10 })
                      .fontSize(24)
                      .fontWeight(600)
                      .textAlign(TextAlign.Start)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .textShadow(ThemeColor.TextShadow)

                    Flex({justifyContent: FlexAlign.Start}) {
                      ForEach(item.cateDefect, (cate: string, idx: number) => {
                        Text(cate)
                          .fontSize(12)
                          .backgroundColor(item.colorDefect[idx])
                          .fontColor(Color.White)
                          .padding({left: 4, right: 4, bottom: 4, top: 4})
                          .borderRadius(4)
                          .margin({right: 6})
                      })
                    }

                    Text(`任务描述: ${item.taskDesc}`)
                      .fontSize(14)
                      .fontColor(ThemeColor.FontColor)
                      .textAlign(TextAlign.Start)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(2)
                      .margin({bottom: 4, top: 6})
                      .width('70%')
                      .textShadow(ThemeColor.TextShadow)

                    Text(`瑕疵总数: ${item?.countDefect ? item.countDefect : 0}`)
                      .fontSize(14)
                      .fontColor(ThemeColor.FontColor)
                      .textAlign(TextAlign.Start)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .margin({bottom: 4})
                      .textShadow(ThemeColor.TextShadow)

                    Text(`创建日期: ${item.gmtCreate}`)
                      .fontSize(14)
                      .fontColor(ThemeColor.FontColor)
                      .textAlign(TextAlign.Start)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .margin({bottom: 4})
                      .textShadow(ThemeColor.TextShadow)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .width('80%')
                  .margin({ left: 12 })
                }
                // Blank()
                Column() {
                  if (item.taskState == 2) {
                    Button({ type: ButtonType.Normal, stateEffect: false }) {
                      Row() {
                        LoadingProgress().width(20).height(20).margin({ left: 8 }).color('#ffffff')
                        Text('检测中').fontColor('#ffffff').margin({ left: 8, right: 8 })
                      }
                    }
                    .height(36)
                    .width(110)
                    .fontSize(14)
                    .borderRadius(4)
                    .margin({ right: 12 })
                    .backgroundColor('rgb(252, 163, 017)')
                  } else if (item.taskState == 1) {
                    Button({ type: ButtonType.Normal, stateEffect: false }) {
                      Row() {
                        LoadingProgress().width(20).height(20).margin({ left: 8 }).color('#ffffff')
                        Text('上传中').fontColor('#ffffff').margin({ left: 8, right: 8 })
                      }
                    }
                    .height(36)
                    .width(110)
                    .fontSize(14)
                    .borderRadius(4)
                    .margin({ right: 12 })
                    .backgroundColor('rgb(021, 151, 165)')
                  } else if (item.taskState == 0) {
                    Button(
                      item.countDetectImg < item.countAllImg ? `检测 ${item.countDetectImg}/${item.countAllImg}` : `已检测 ${item.countDetectImg}/${item.countAllImg}`,
                      { type: ButtonType.Normal, stateEffect: item.countDetectImg < item.countAllImg ? true : false }
                    )
                      .onClick(() => {
                        if (item.countDetectImg < item.countAllImg) {
                          this.selectedId = item.taskId;
                          AlertDialog.show(
                            {
                              title: '是否开始检测?',
                              message: '',
                              autoCancel: true,
                              alignment: DialogAlignment.Center,
                              gridCount: 4,
                              offset: { dx: 0, dy: -20 },
                              primaryButton: {
                                value: '取消',
                                fontColor: '#000000',
                                backgroundColor: '#ffffff',
                                action: () => {
                                  this.selectedId = -1;
                                }
                              },
                              secondaryButton: {
                                value: '确定',
                                fontColor: '#000000',
                                backgroundColor: '#ffffff',
                                action: () => {
                                  this.startDet(item.taskId);
                                }
                              },
                              cancel: () => {
                                this.selectedId = -1;
                              }
                            }
                          )
                        }
                      })
                      .borderRadius(4)
                      .height(36)
                      .width(110)
                      .backgroundColor('rgba(0, 0, 0, 0)')
                      .radialGradient(ThemeColor.DisableButtonRadialGradient("rgb(7, 193, 96)", item.countDetectImg >= item.countAllImg))
                      // .background(DisableBackground('rgb(7, 193, 96)', 0.5, item.countDetectImg >= item.countAllImg))
                      // .enabled(item.countDetectImg < item.countAllImg)
                      .fontSize(16)
                      .shadow(ThemeColor.Shadow)
                  }
                }
                .position({x: '68%', y: '70%'})
              }
              .padding({top: -20})
              .height('100%')
            }
          }
          .onClick(() => {
            if (!this.openBatchDel) {
              router.pushUrl({
                "url": "pages/TaskImg",
                "params": item
              })
            } else {
              if (this.chooseTaskIdx.includes(item.taskId)) {
                this.chooseTaskIdx = this.chooseTaskIdx.filter((i: number) => i != item.taskId)
              } else {
                this.chooseTaskIdx.push(item.taskId)
              }
            }
          })
          .gesture(
            // 长按提示是否删除
            LongPressGesture({repeat: false, duration: 1000})
              .onAction((event: GestureEvent | undefined) => {
                if (event) {
                  this.showDelDialog(index)
                }
              })
          )
          // .width('100%')
          .height(150)
          .borderRadius(8)
          .shadow(ThemeColor.Shadow)
          .padding({top: 16, bottom: 10})
          .background(Background(getContext(this), item.taskId.toString()))
      }
      .padding(4)
      .swipeAction({
        end: {
          builder: () => { this.itemEnd(index)}
        }
      })
  }

  // 检测某一任务
  startDet (selectedId: number) {
    startDet({
      taskId: selectedId
    }, '开始检测')
      .then((res: Response) => {
        if (res.status == 200) {
          setTimeout(() => {
              this.getTasks();
          }, requestTime)
        }
        this.selectedId = -1;
      })
      .catch((err: Response) => {
        this.selectedId = -1;
      })
  }

  // 计算单任务的瑕疵类别和总量
  computeFlawNum(flawInfo: Map<string, number>): object {
    let totalNum = 0;
    let totalCate: Array<string> = [];
    let totalColor: Array<string> = [];
    Object.keys(flawInfo).forEach((v, i) => {
      if (flawInfo[v] > 0) {
        totalCate.push(cateFlowMap[v]);
        totalColor.push(colorFlowMap[v])
        totalNum += flawInfo[v];
      }
    })

    return new Object({
      'countDefect': totalNum,
      'cateDefect': totalCate,
      'colorDefect': totalColor
    })
  }

  // 获取任务列表
  getTasks (params: object | null = null, showLoading: boolean = true) {
    this.showLoading = showLoading;
    return getTasks(params)
      .then((res: Response) => {
        console.log("获取任务成功:"+  JSON.stringify(res));
        let tempList: Array<TaskElem> = [];
        for (let i = 0; i < res.result.length; i++) {
          let taskInfo = res.result[i];

          let flawInfo = this.computeFlawNum(taskInfo['countDefect'])

          let taskObj: TaskElem = new TaskElem(
            taskInfo['taskId'],
            taskInfo['taskName'],
            taskInfo['taskDesc'],
            taskInfo['harmonyUserId'],
            taskInfo['taskState'],
            taskInfo['gmtCreate'],
            taskInfo['countDetectImg'],
            taskInfo['countAllImg'],
            taskInfo['taskCoverImg'],
            flawInfo['countDefect'],
            flawInfo['cateDefect'],
            flawInfo['colorDefect']
          )
          tempList.push(taskObj);
        }
        this.taskList = [...tempList];
        setTimeout(() => {
          this.showLoading = false;
        }, requestTime)
      })
      .catch((err: Response) => {
        this.showLoading = false;
      })
  }

  build() {
    Column() {
      Loading({ show: this.showLoading })
      Notice({noticeController: this.noticeController})
      if (this.taskList.length === 0) {
        if (!this.showLoading) {
          Empty({ extraContent: '点击右上角创建检测任务' })
            .backgroundColor(ThemeColor.BackgroundColor)
        }
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: 18, initialIndex: 0 }) {
            ForEach(this.taskList, (item: TaskElem, index: number) => {
              this.TaskItem(item, index)
            })
          }
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Off)
          .friction(0.6)
          .divider({
            strokeWidth: 1,
            color: 'rgb(240, 250, 239)',
            startMargin: 20,
            endMargin: 20
          })
          .edgeEffect(EdgeEffect.Spring)
          .padding({ left: 8, right: 8, top: 10, bottom: 10 })
          .width('100%')
          .height('100%')
        }
        .height('100%')
        .width('100%')
        .backgroundColor(ThemeColor.BackgroundColor)
        .onRefreshing(() => {
          this.getTasks(null, false).then(()=>this.isRefreshing = false);
          console.log('onRefreshing test')
        })
        .refreshOffset(120)
        .pullToRefresh(true)
      }
    }
  }
}