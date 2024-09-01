import router from '@ohos.router';
import { Response, TaskElem } from '../common/classes'
import { delTask, getTasks, startDet } from '../api/service'
import { TaskController } from '../controllers/TaskController';
import { Empty } from '../components/Empty';


@Component
export struct Task {
  @Link openBatchDel: boolean;
  @Link chooseTaskIdx: Array<number>;

  @State message: string = '任务列表';
  @State isRefreshing: boolean = false;
  @State taskList: Array<TaskElem> = [];
  @State selectedId: number = -1;

  @StorageLink("token") token: object | null = null;

  public taskController: TaskController | null = null;


  // 生命钩子函数
  aboutToAppear(){
    if (!this.token)
      router.replaceUrl({url: 'pages/Login'})
    if (this.taskController) {
      this.taskController.attach(this); //绑定控制器
    }
    this.getTasks();
  }

  @Builder TaskItem(item: TaskElem) {
      Row() {
        Flex({alignItems: ItemAlign.Center}) {
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
        Column() {
          Text(item.taskName)
            .margin({bottom: 10})
            .fontSize(24)
            .fontWeight(600)
            .textAlign(TextAlign.Start)
          Text(item.taskDesc)
            .fontSize(14)
            .fontColor('rgb(127, 127, 127)')
            .textAlign(TextAlign.Start)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .width(120)
        .margin({left: 20})
        Blank()
          if (item.taskState == 2) {
            Button({type: ButtonType.Normal, stateEffect: false}) {
              Row() {
                LoadingProgress().width(20).height(20).margin({left: 8}).color('#ffffff')
                Text('检测中').fontColor('#ffffff').margin({left: 8, right:8}).enabled(false)
              }
              .width(96)
              .height(36)
            }
              .borderRadius(4)
              .margin({right: 12})
              .backgroundColor('rgb(233, 196, 107)')
          }
          else if (item.taskState == 1) {
            Button({type: ButtonType.Normal, stateEffect: false}) {
              Row() {
                LoadingProgress().width(20).height(20).margin({left: 8}).color('#ffffff')
                Text('上传中').fontColor('#ffffff').margin({left: 8, right:8})
              }
              .height(36)
              .width(96)
            }
              .borderRadius(4)
              .margin({right: 12})
              .backgroundColor('rgb(021, 151, 165)')
          }
          else if (item.taskState == 0) {
            Button(
              `检测 ${item.countDetectImg}/${item.countAllImg}`,
              {type: ButtonType.Normal, stateEffect: item.countDetectImg < item.countAllImg ? true: false}
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
              .margin({right: 12})
              .height(36)
              .width(96)
              .backgroundColor('rgb(7, 193, 96)')
              .enabled(item.countDetectImg < item.countAllImg)
          }
        }
        .height('100%')
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
                          console.log('删除任务成功', JSON.stringify(res));
                          this.getTasks()
                      })
                        .catch((err: Response) => {
                          console.log('删除任务失败', JSON.stringify(err));
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
      .width('100%')
      .height(100)
      .backgroundColor(0xFFFFFF)
      .borderRadius(12)
  }

  // 检测某一任务
  startDet (selectedId: number) {
    startDet({
      taskId: selectedId
    })
      .then((res: Response) => {
        console.log('开始检测', JSON.stringify(res));
        this.getTasks();
        this.selectedId = -1;
      })
      .catch((err: Response) => {
        console.log("检测失败:" + JSON.stringify(err))
      })
  }

  // 获取任务列表
  getTasks () {
    getTasks()
      .then((res: Response) => {
        console.log("获取任务成功:"+  JSON.stringify(res));
        let tempList: Array<TaskElem> = [];
        for (let i = 0; i < res.result.length; i++) {
          let taskInfo = res.result[i];
          let taskObj: TaskElem = new TaskElem(
            taskInfo['taskId'],
            taskInfo['taskName'],
            taskInfo['taskDesc'],
            taskInfo['harmonyUserId'],
            taskInfo['taskState'],
            taskInfo['gmtCreate'],
            taskInfo['countDetectImg'],
            taskInfo['countAllImg'],
          )
          tempList.push(taskObj)
        }
        this.taskList = [...tempList]
      })
      .catch((err: Response) => {
        console.log("获取任务失败:" + JSON.stringify(err))
      })
  }

  build() {
    if (this.taskList.length === 0) {
      Empty()
        .backgroundColor(0xDCDCDC)
    } else {
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ space: 20, initialIndex: 0 }) {
          ForEach(this.taskList, (item: TaskElem) => {
            this.TaskItem(item)
          })
        }
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .friction(0.6)
        .divider({
          strokeWidth: 2,
          color: 'rgb(240, 250, 239)',
          startMargin: 20,
          endMargin: 20
        })
        .edgeEffect(EdgeEffect.Spring)
        .onScrollIndex((firstIndex: number, lastIndex: number, centerIndex: number) => {
          console.info('first' + firstIndex)
          console.info('last' + lastIndex)
          console.info('center' + centerIndex)
        })
        .onScrollVisibleContentChange((start: VisibleListContentInfo, end: VisibleListContentInfo) => {
          console.log(' start index: ' + start.index +
            ' start item group area: ' + start.itemGroupArea +
            ' start index in group: ' + start.itemIndexInGroup)
          console.log(' end index: ' + end.index +
            ' end item group area: ' + end.itemGroupArea +
            ' end index in group: ' + end.itemIndexInGroup)
        })
        .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
          console.info(`onScroll scrollState = ScrollState` + scrollState + `, scrollOffset = ` + scrollOffset)
        })
        .width('100%')
        .padding({ left: 8, right: 8, top: 10 })
        .height('100%')
      }
      .height('100%')
      .width('100%')
      .backgroundColor(0xDCDCDC)
      .onRefreshing(() => {
        this.getTasks();
        // this.isRefreshing = false
        setTimeout(() => {
          this.isRefreshing = false
        }, 1000)
        console.log('onRefreshing test')
      })
      .refreshOffset(64)
      .pullToRefresh(true)
    }
  }
}