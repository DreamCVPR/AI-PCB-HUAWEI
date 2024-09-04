import router from '@ohos.router';
import { Response, TaskElem } from '../common/classes'
import { delTask, getTasks, startDet } from '../api/service'
import { TaskController } from '../controllers/TaskController';
import { Empty } from '../components/Empty';
import { Loading } from '../components/Loading';
import { cateFlowMap, noticeTime, requestTime, colorFlowMap } from '../common/settings';
import { Notice } from '../components/Notice';
import { NoticeController } from '../controllers/NoticeController';


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


  @Builder itemEnd(index: number) {
    Row() {
      Image($r('app.media.delete4'))
        .width(40)
        .height(40)
        .onClick(() => {
          AlertDialog.show(
            {
              title: '是否删除该任务?',
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
                  delTask({
                    taskIds: this.taskList[index].taskId
                  })
                    .then((res: Response) => {
                      if (res.status == 200) {
                        this.noticeController.success(`已删除1项任务`);
                        setTimeout(() => {
                          this.noticeController.close();
                          this.getTasks();
                        }, requestTime)
                      }
                      else {
                        this.noticeController.success(`删除任务失败`);
                        setTimeout(() => {
                          this.noticeController.close();
                        }, noticeTime)
                      }
                    })
                    .catch((err: Response) => {
                      this.noticeController.success(`删除任务失败`);
                      setTimeout(() => {
                        this.noticeController.close();
                      }, noticeTime)
                    })
                }
              },
              cancel: () => {
                this.selectedId = -1;
              }
            }
          )
        })
    }
    .margin({right: 10})
  }

  // 任务单项
  @Builder TaskItem(item: TaskElem, index: number) {
      ListItem() {
          Badge({
            count: item?.countDefect,
            position: BadgePosition.RightTop,
            style: { badgeSize: 20, badgeColor: '#FA2A2D' }
          })
          {
            Flex({ alignItems: ItemAlign.Center }) {
              if (this.openBatchDel) {
                Checkbox()
                  .select(this.chooseTaskIdx.includes(item.taskId))
                  .selectedColor(0x39a2db)
                  .shape(CheckBoxShape.ROUNDED_SQUARE)
                  .onClick(() => {
                    if (this.chooseTaskIdx.includes(item.taskId)) {
                      this.chooseTaskIdx = this.chooseTaskIdx.filter((i: number) => i != item.taskId)
                    } else {
                      this.chooseTaskIdx.push(item.taskId)
                    }
                    console.log('this.chooseTaskIdx: ' + this.chooseTaskIdx)
                  })
                  .position({ top: 2, right: 2 })
                  .borderColor(Color.White)
              }
              Row() {
                Column() {
                  Row() {
                    Text(item.taskName)
                      .margin({ bottom: 10 })
                      .fontSize(24)
                      .fontWeight(600)
                      .textAlign(TextAlign.Start)

                    Flex({justifyContent: FlexAlign.Start}) {
                      ForEach(item.cateDefect, (cate: string, idx: number) => {
                          Text(cate)
                            .fontSize(12)
                            .backgroundColor(item.colorDefect[idx])
                            .fontColor(Color.White)
                            .padding({left: 4, right: 4, bottom: 4, top: 4})
                            .borderRadius(4)
                            .margin({left: 6})
                      })
                    }
                  }

                  Text(`任务描述: ${item.taskDesc}`)
                    .fontSize(14)
                    .fontColor('rgb(127, 127, 127)')
                    .textAlign(TextAlign.Start)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                  Text(`瑕疵总数: ${item?.countDefect ? item.countDefect : 0}`)
                    .fontSize(14)
                    .fontColor('rgb(127, 127, 127)')
                    .textAlign(TextAlign.Start)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                  Text(`创建日期: ${item.gmtCreate}`)
                    .fontSize(14)
                    .fontColor('rgb(127, 127, 127)')
                    .textAlign(TextAlign.Start)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                }
                .alignItems(HorizontalAlign.Start)
                .width('80%')
                .margin({ left: 20 })
              }

              // Blank()
              Column() {
                if (item.taskState == 2) {
                  Button({ type: ButtonType.Normal, stateEffect: false }) {
                    Row() {
                      LoadingProgress().width(20).height(20).margin({ left: 8 }).color('#ffffff')
                      Text('检测中').fontColor('#ffffff').margin({ left: 8, right: 8 }).enabled(false)
                    }
                    .width(96)
                    .height(36)
                  }
                  .borderRadius(4)
                  .margin({ right: 12 })
                  .backgroundColor('rgb(233, 196, 107)')
                } else if (item.taskState == 1) {
                  Button({ type: ButtonType.Normal, stateEffect: false }) {
                    Row() {
                      LoadingProgress().width(20).height(20).margin({ left: 8 }).color('#ffffff')
                      Text('上传中').fontColor('#ffffff').margin({ left: 8, right: 8 })
                        .fontSize(14)
                    }
                    .height(36)
                    .width(110)
                  }
                  .borderRadius(4)
                  .margin({ right: 12 })
                  .backgroundColor('rgb(021, 151, 165)')
                } else if (item.taskState == 0) {
                  Button(
                    `检测 ${item.countDetectImg}/${item.countAllImg}`,
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
                    .width(120)
                    .backgroundColor('rgb(7, 193, 96)')
                    .enabled(item.countDetectImg < item.countAllImg)
                    .fontSize(14)
                }
              }
              .position({x: '65%', y: '50%'})
              // .margin({top: 20})
            }
            .height('100%')
          }
      }
      .onClick(() => {
        router.pushUrl({
          "url": "pages/TaskImg",
          "params": item
        })
        // TODO: 进入任务详情页
      })
      .gesture(
        // 长按提示是否删除
        LongPressGesture({repeat: false, duration: 1000})
          .onAction((event: GestureEvent | undefined) => {
            if (event) {
              AlertDialog.show(
                {
                  title: '是否删除该任务?',
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
                      delTask({
                        taskIds: item.taskId
                      })
                        .then((res: Response) => {
                          if (res.status == 200) {
                            this.noticeController.success(`已删除1项任务`);
                            setTimeout(() => {
                              this.noticeController.close();
                              this.getTasks();
                            }, requestTime)
                          }
                          else {
                            this.noticeController.success(`删除任务失败`);
                            setTimeout(() => {
                              this.noticeController.close();
                            }, noticeTime)
                          }
                      })
                        .catch((err: Response) => {
                          this.noticeController.success(`删除任务失败`);
                          setTimeout(() => {
                            this.noticeController.close();
                          }, noticeTime)
                        })
                    }
                  },
                  cancel: () => {
                    this.selectedId = -1;
                  }
                }
              )
            }
          })
      )
      // .width('100%')
      .height(100)
      .backgroundColor(0xFFFFFF)
      .borderRadius(6)
      .shadow({ radius: 12, color: '#ffffff', offsetX: 0, offsetY: 0 })
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
    })
      .then((res: Response) => {
        if (res.status == 200) {
          this.noticeController.success('开始检测')
          setTimeout(() => {
              this.noticeController.close();
              this.getTasks();
              this.selectedId = -1;
          }, requestTime)
        }
        else {
          this.noticeController.success(JSON.stringify(res.message))
          setTimeout(() => {
            this.noticeController.close();
            this.selectedId = -1;
          }, noticeTime)
        }
      })
      .catch((err: Response) => {
        this.noticeController.fail('检测失败')
        setTimeout(() => {
            this.noticeController.close();
        }, noticeTime)
      })
  }

  // 计算单任务的瑕疵类别和总量
  computeFlawNum(flawInfo: Map<string, number>): object {
    let totalNum = 0;
    let totalCate: Array<string> = [];
    let totalColor: Array<string> = [];
    Object.keys(flawInfo).forEach((v, i) => {
      totalCate.push(cateFlowMap[v]);
      totalColor.push(colorFlowMap[v])
      totalNum += flawInfo[v];
    })

    return new Object({
      'countDefect': totalNum,
      'cateDefect': totalCate,
      'colorDefect': totalColor
    })
  }

  // 获取任务列表
  getTasks (params: object | null = null) {
    this.showLoading = true;
    getTasks(params)
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
        setTimeout(() => {
          this.showLoading = false;
          this.noticeController.fail('查询任务失败');
          setTimeout(() => {
            this.noticeController.close();
          }, noticeTime)
        }, requestTime)
      })
  }

  build() {
    Column() {
      Loading({ show: this.showLoading })
      Notice({noticeController: this.noticeController})
      if (this.taskList.length === 0) {
        Empty({ extraContent: '点击右上角创建检测任务' })
          .backgroundColor(0xDCDCDC)
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
        .backgroundColor(0xDCDCDC)
        .onRefreshing(() => {
          this.getTasks();
          setTimeout(() => {
            this.isRefreshing = false;
          }, requestTime)
          console.log('onRefreshing test')
        })
        .refreshOffset(120)
        .pullToRefresh(true)
      }
    }
  }
}