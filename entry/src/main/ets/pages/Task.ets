import router from '@ohos.router';
import { Response, TaskElem } from '../common/classes'
import { detect, getTasks } from '../api/service'

@Entry
@Component
export struct Task {
  @State message: string = '任务列表';
  @State taskList: Array<object> = [];
  @State selectedId: number = -1;

  @Builder TaskItem(item: TaskElem) {
      Row() {
        Column() {
          Text(item.taskName)
          Text(item.taskDesc)
        }
        Blank()
        Button('检测')
          .onClick(() => {
            this.startDet(item.taskId);
          })
      }
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
          this.taskList.push(taskObj)
        }
      })
      .catch((err: Response) => {
        console.log("获取任务失败:" + JSON.stringify(err))
      })
  }

  // 生命钩子函数
  aboutToAppear(){
    this.getTasks()
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
      .width('90%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor(0xDCDCDC)
    .padding({top: 5})
  }
}