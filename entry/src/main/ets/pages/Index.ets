import { router } from '@kit.ArkUI';
import { Settings } from './Settings'
import { Visual } from '../pages/Visual'
import { Task } from './Task'
import { NVElem, CommonConstants, RouRefresh, Response } from '../common/classes'
import { TaskController } from '../controllers/TaskController'
import { delTask } from '../api/service';


@Entry
@Component
struct Index {
  private tabController: TabsController = new TabsController()
  private taskController: TaskController = new TaskController()
  @State currentIndex: number = 0;
  @State showTask: boolean = false;
  @State helpPopup: boolean = false;
  @State title: string = '首页';
  @State openBatchDel: boolean = false;
  @State chooseTaskIdx: Array<number> = [];

  @StorageLink("token") token: object | null = null;

  @State tabs: Array<NVElem> = [
    {
      text: '首页',
      num: 0,
      init: 'app.media.home',
      selected: 'app.media.home_selected',
      page: 'pages/Index',
    },
    {
      text: '数据面板',
      num: 1,
      init: 'app.media.vis',
      selected: 'app.media.vis_selected',
      page: 'pages/Visual',
    },
    {
      text: '我的',
      num: 2,
      init: 'app.media.settings',
      selected: 'app.media.settings_selected',
      page: 'pages/Settings',
    }
  ]

  aboutToAppear(): void {
    if (!this.token)
      router.replaceUrl({url: 'pages/Login'})
  }


  @Builder TabBuilder(index: number) {
    Column() {
      Image(this.currentIndex === this.tabs[index].num ? $r(this.tabs[index].selected) : $r(this.tabs[index].init))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Contain)
      Text(this.tabs[index].text)
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width('100%')
  }

  @Builder Nav(): void {
    Row() {
      Row() {
        Text(this.title)
          .fontColor('#ffffff')
          .fontSize(20)
          .fontWeight(700)
          .textAlign(TextAlign.Start)
          .margin({ left: 2 })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .width('20%')

      Row() {
        Text(this.openBatchDel ? '完成': '')
          .fontColor('#ffffff')
          .fontSize(20)
          .fontWeight(700)
          .textAlign(TextAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('50%')
      .padding({left: '10%'})
      .enabled(this.openBatchDel)
      .onClick(() => {
        AlertDialog.show(
          {
            title: '是否删除?',
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
              }
            },
            secondaryButton: {
              value: '确定',
              fontColor: '#000000',
              backgroundColor: '#ffffff',
              action: () => {
                let taskIds = this.chooseTaskIdx.join(',')
                delTask({
                  taskIds: taskIds
                })
                  .then((res: Response) => {
                    console.log('删除任务成功', JSON.stringify(res));
                    this.chooseTaskIdx = [];
                    this.openBatchDel = false;
                    this.taskController?.getTasks();
                })
                  .catch((err: Response) => {
                    console.log('删除任务失败', JSON.stringify(err));
                  })
              }
            },
            cancel: () => {

            }
          })
      })

      // Blank()
      Row() {
        if (this.currentIndex == 0) {
          Image($r('app.media.help'))
            .width(26)
            .height(26)
            .margin({ right: 16 })
            .onClick(() => {
              this.helpPopup = !this.helpPopup;
            })
            .bindPopup(this.helpPopup, {
              message: '需先创建PCB检测任务, 再执行检测',
              placementOnTop: true,
              showInSubWindow: false,
              onStateChange: (e) => {
                console.info(JSON.stringify(e.isVisible))
                if (!e.isVisible) {
                  this.helpPopup = false
                }
              },
            })

          Image($r('app.media.add2'))
            .width(26)
            .height(26)
            .onClick(() => {
              console.log('进入增加任务页面')
              router.pushUrl({ url: 'pages/AddTask' })
            })
            .margin({ right: 16 })

          Image(this.openBatchDel ? $r('app.media.waste') : $r('app.media.multi_choose'))
            .width(26)
            .height(26)
            .onClick(() => {
              console.log('批量删除');
              this.openBatchDel = !this.openBatchDel;
              this.chooseTaskIdx = [];
            })
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.End)
      .width('30%')
    }
    .width('100%')
    .height(CommonConstants.STATUS_BAR_HEIGHT - 30)
    .backgroundColor('rgb(130, 178, 154)')
    .padding({
      left: 10,
      right: 10,
      top: 30,
      bottom: 0
    })
  }

  @Builder Body(): void {
    // 主体
    Row() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
        ForEach(this.tabs, (item: NVElem) => {
          TabContent() {
            Column() {
              if (item.num === 0) {
                Task({
                  openBatchDel: this.openBatchDel,
                  chooseTaskIdx: this.chooseTaskIdx,
                  taskController: this.taskController,
                });
              } else if (item.num === 1) {
                Visual();
              } else if (item.num === 2) {
                Settings();
              }
            }.width('100%')
          }.tabBar(this.TabBuilder(item.num))
        })

      }
      .onChange((index: number) => {
        this.updateTitle(this.tabs[index].text)
        this.currentIndex = index
      })
      .animationDuration(0)
      .barWidth('100%')
      // .scrollable(false)
      .barMode(BarMode.Fixed)
      .vertical(false)
      .barHeight(56)
      .margin({ bottom: 16 })
    }
  }


  // 强制刷新
  onPageShow(): void {
    const params = router.getParams() as RouRefresh
    if (params) {
      const refresh: boolean = params.refresh
      if (refresh)
        this.taskController.getTasks();
    }
  }

  // 更新title
  updateTitle(title: string): void {
    this.title = title
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // 导航栏
        this.Nav()

        // 主体
        this.Body()

      }.width('100%').height('100%')

    }
  }
}