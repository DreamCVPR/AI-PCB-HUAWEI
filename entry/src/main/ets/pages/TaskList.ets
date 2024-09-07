import router from '@ohos.router';
import { Response, TaskElem } from '../common/classes'
import { delTask, getTasks, startDet } from '../api/service'
import { TaskController } from '../controllers/TaskController';
import { Empty } from '../components/Empty';
import { Loading } from '../components/Loading';
import { NoticeController } from '../controllers/NoticeController';
import { Background } from '../builder/Background';
import { ThemeColor } from '../common/settings';
import { changeTask } from '../api/taskImg';
import { curves } from '@kit.ArkUI';

@Entry
@Component
struct TaskList {
  @State taskId: number = (router.getParams() as object)['taskId'];
  @State imgIds: number = (router.getParams() as object)['imgIds'];

  @State taskList: Array<object> = [];
  @State showLoading: boolean = false;
  @State message: string = '任务列表';
  @State searchText: string = "";
  @State isRefreshing: boolean = false;
  @State animate: boolean = true;

  @StorageLink("token") token: string = '';

  // 生命钩子函数
  aboutToAppear(){
    this.getTasks();
  }

  @Builder TopBar() {
    Row() {
      Flex() {
        Row() {
          Image($r('app.media.left_arrow'))
            .fillColor(ThemeColor.NavConfig['FontColor'])
            .height(25)
            .width(25)
            .visibility(this.animate ? Visibility.Visible : Visibility.None)
            .position({bottom: -1})
            .onClick(()=>{
              router.back()
            })
          Text("选择目标任务")
            .fontColor(ThemeColor.NavConfig['FontColor'])
            .fontSize(20)
            .fontWeight(400)
            .textAlign(TextAlign.Start)
            .margin({ left: 10+27 })
        }
        .position({ top: 20, left: 2 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .visibility(this.animate ? Visibility.Visible : Visibility.None)
        .width(200)
        Row() {
          Image($r('app.media.search'))
            .width(30)
            .height(30)
            .margin({ right: 8 })
            .fillColor(ThemeColor.NavConfig['FontColor'])
            .rotate({ angle: !this.animate ? 90 : 0 })
            .translate({ x: !this.animate ? -300 : 0 })
            .visibility(this.animate ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              animateTo({ curve: curves.springMotion() }, () => {
                this.animate = !this.animate;
              })
            })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .width('30%')
        .position({ top: 16, right: 10 })
        Search({ placeholder: '请输入任务名称', value: this.searchText })
          .width("90%")
          .height(30)
          .position({top: 6, left: 2})
          .zIndex(10)
          .visibility(!this.animate ? Visibility.Visible : Visibility.None)
          .onChange((value: string) => {
            this.searchText = value
          })
          .onSubmit((value: String) => {
            this.getTasks(new Object({taskName: this.searchText.replace(" ", "")}));
          })
        Image($r('app.media.close'))
          .width(25)
          .height(25)
          .fillColor("#F3F3F3")
          .position({top: 16, right: 0})
          .zIndex(10)
          .visibility(!this.animate ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            animateTo({ curve: curves.springMotion() }, () => {
              this.animate = !this.animate;
            })
            this.searchText = ""
            this.getTasks()
          })
      }.width('100%').height("100%")
    }
    .width('100%')
    .height(AppStorage.get('statusBarHeight') as number - 30)
    .backgroundColor(ThemeColor.NavConfig['BackgroundColor'])
    .padding({
      left: 10,
      right: 10,
      top: 30,
      bottom: 0
    })
  }

  // 任务单项
  @Builder TaskItem(item: TaskElem, index: number) {
    ListItem() {
      Flex({ alignItems: ItemAlign.Center }) {
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
      }
      .height('100%')
      .onClick(() => {
        this.showLoading = true
        changeTask({"taskId": item.taskId, "imgIds": this.imgIds}).then(()=>{
          router.back()
          router.replaceUrl({
            "url": "pages/TaskImg",
            "params": item
          })
        })
      })
      .height(120)
      .padding({top: 16, left: 10, right:10, bottom: 10})
      .padding({top: 16, bottom: 10})
      .background(Background(getContext(this), item.taskId.toString()))
      .borderRadius(8)
      .shadow(ThemeColor.Shadow)
    }
    .padding(4)
  }

  getTasks (params: object | null = null) {
    this.showLoading = true;
    getTasks(params)
      .then((res: object) => {
        this.showLoading = false
        this.taskList = (res["result"] as Array<object>).filter(task=>task["taskId"] !== this.taskId);
      })
      .catch((err: object) => {
        this.showLoading = false
      })
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // 顶部导航栏
        this.TopBar()
        Flex({ direction: FlexDirection.Column }) {
          Stack() {
            Loading({ show: this.showLoading })
            if (this.taskList.length === 0) {
              if (!this.showLoading) {
                Empty({ extraContent: '暂无其他任务' })
                  .backgroundColor(ThemeColor.BackgroundColor)
              }
            } else {
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
              .padding({
                left: 8,
                right: 8,
                top: 10,
                bottom: 10
              })
              .width('100%')
              .height('100%')
            }
          }
          .backgroundColor(ThemeColor.BackgroundColor)
        }.width('100%').height('100%')
      }.width('100%').height('100%')
    }.width('100%').height('100%')
  }
}