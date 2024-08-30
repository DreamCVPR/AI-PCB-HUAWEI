import router from '@ohos.router';
import { Response, TaskElem } from '../common/classes'
import { detect, getTasks } from '../api/service'
import { TaskController } from '../controllers/TaskController';


@Entry
@Component
export struct Task {
  @State message: string = '任务列表';
  @State taskList: Array<TaskElem> = [new TaskElem(
    48,
    "任务1",
    "这是任务1",
    "1",
    1,
    "2024-08-30 14:09:43"
  ),new TaskElem(
    48,
    "任务2",
    "这是任务weqweqww2",
    "1",
    0,
    "2024-08-30 14:09:43"
  ),
    new TaskElem(
      48,
      "任务2",
      "这是任务weqweqww2",
      "1",
      2,
      "2024-08-30 14:09:43"
    )];
  @State selectedId: number = -1;

  public taskController: TaskController | null = null;

  // 生命钩子函数
  aboutToAppear(){
    if (this.taskController) {
      this.taskController.attach(this); //绑定控制器
    }
    this.getTasks();
  }

  @Builder TaskItem(item: TaskElem) {
      Row() {
        Flex({alignItems: ItemAlign.Center}) {
        Column() {
          Text(item.taskName)
            .margin({bottom: 10})
            .fontSize(22)
            .fontWeight(600)
            .textAlign(TextAlign.Start)
          Text(item.taskDesc)
            .fontSize(12)
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
                Text('检测中').fontColor('#ffffff').margin({left: 8, right:8})
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
              .onClick(() => {
                this.startDet(item.taskId);
                this.getTasks();
              })
              .borderRadius(4)
              .margin({right: 12})
              .backgroundColor('rgb(021, 151, 165)')
          }
          else if (item.taskState == 0) {
            Button('检测', {type: ButtonType.Normal, stateEffect: true})
              .onClick(() => {
                this.startDet(item.taskId);
                this.getTasks();
              })
              .borderRadius(4)
              .margin({right: 12})
              .height(36)
              .width(96)
              .backgroundColor('rgb(042, 157, 142)')
          }
        }
        .height('100%')
      }
      .width('100%')
      .height(100)
      .backgroundColor(0xFFFFFF)
      .borderRadius(12)
  }

  // 检测某一任务
  startDet (selectedId: number) {
    detect({
      taskId: selectedId
    })
      .then((res: Response) => {
        console.log('开始检测', JSON.stringify(res));
        this.selectedId = selectedId;
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
            taskInfo['gmtCreate']
          )
          tempList.push(taskObj)
          this.taskList = [...tempList]
        }
      })
      .catch((err: Response) => {
        console.log("获取任务失败:" + JSON.stringify(err))
      })
  }

  build() {
    RelativeContainer() {
      List({space: 20, initialIndex: 0}) {
        ForEach(this.taskList, (item: TaskElem) => {
          this.TaskItem(item)
        })
      }
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .friction(0.6)
      .divider({
        strokeWidth: 2, color: 0xFFFFFF, startMargin: 20, endMargin: 20
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
      .padding({left: 8, right: 8, top: 10})
      .height('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor(0xDCDCDC)
  }
}