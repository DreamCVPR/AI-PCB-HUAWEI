import { LoadingDialog, router } from '@kit.ArkUI';
import { Settings } from './Settings'
import { Visual } from '../pages/Visual'
import { Task } from './Task'
import { NVElem, CommonConstants, RouRefresh, Response, TaskElem } from '../common/classes'
import { TaskController } from '../controllers/TaskController'
import { delTask, getTasks } from '../api/service';


@Entry
@Component
struct Index {
  private tabController: TabsController = new TabsController()
  private taskController: TaskController = new TaskController()
  @State currentIndex: number = 0;
  @State showTask: boolean = false;
  @State helpPopup: boolean = false;
  @State title: string = '任务';
  @State openBatchDel: boolean = false;
  @State chooseTaskIdx: Array<number> = [];
  @State taskList: Array<TaskElem> = [];
  @State tabs: Array<NVElem> = [
    {
      text: '任务 ',
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

  @StorageLink("token") token: string = ''


  dialogControllerProgress: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '处理中...',
    }),
  })

  aboutToAppear(): void {
    if (this.token === '')
      router.replaceUrl({url: 'pages/Login'})
  }


  @Builder TabBuilder(index: number) {
    Column() {
      Image($r(this.tabs[index].init))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Contain)
        .fillColor(
          this.currentIndex === this.tabs[index].num ? '#000000': '#aaaaaa')
      Text(this.tabs[index].text)
        .fontSize(12)
        .fontWeight(500)
        .lineHeight(14)
        .fontColor(
          this.currentIndex === this.tabs[index].num ? '#000000': '#aaaaaa'
        )
    }.width('100%')
  }

  @Builder TaskSortSubMenu() {
    Menu() {
      MenuItem({startIcon: $r('app.media.deting'), content: '检测中'})
        .onClick(() => {
          console.log('按照“检测中”状态进行查询')
          this.dialogControllerProgress?.open()
          this.taskController.getTasks(Object({taskState: 2}))
          this.dialogControllerProgress?.close()
        })
      MenuItem({startIcon: $r('app.media.deted'), content: '空闲'})
        .onClick(() => {
          console.log('按照“空闲”状态进行查询')
          this.dialogControllerProgress?.open()
          this.taskController.getTasks(Object({taskState: 0}))
          this.dialogControllerProgress?.close()
        })
      MenuItem({startIcon: $r('app.media.time'), content: '创建时间'})
        .onClick(() => {
          console.log('按照“创建时间”状态进行查询')
          this.dialogControllerProgress?.open()
          this.taskController.getTasks();
          this.dialogControllerProgress?.close()
        })
    }
  }

  @Builder TaskMenu() {
    Menu() {
      MenuItem({startIcon: $r('app.media.add'), content: '增加任务'})
        .onClick(() => {
          console.log('进入增加任务页面')
          router.pushUrl({ url: 'pages/AddTask' })
        })
      MenuItem({startIcon: $r('app.media.delete3'), content: '删除任务'}).enabled(this.taskList.length > 0)
        .onClick(() => {
          console.log('批量删除');
          this.openBatchDel = !this.openBatchDel;
          this.chooseTaskIdx = [];
        })
      MenuItem({
        startIcon: $r('app.media.menu_left'),
        content: '排序任务',
        builder: this.TaskSortSubMenu
      })
        .enabled(this.taskList.length > 0)

      MenuItem({startIcon: $r('app.media.help'), content: '帮助'})
        .onTouch(() => {
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
    }
  }

  @Builder Nav(): void {
    if (this.currentIndex == 0) {
      Row() {
        Row() {
          Text(`${this.title}(${this.taskList.length})`)
            .fontColor('#000000')
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .margin({ left: 2, top: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width('30%')

        Row() {
          Text(this.openBatchDel ? '完成' : '')
            .fontColor('#000000')
            .fontSize(20)
            .textAlign(TextAlign.Start)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('40%')
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
                  this.chooseTaskIdx = [];
                  this.openBatchDel = false;
                }
              },
              secondaryButton: {
                value: '确定',
                fontColor: '#000000',
                backgroundColor: '#ffffff',
                enabled: this.chooseTaskIdx.length > 0,
                action: () => {
                  this.dialogControllerProgress.open();
                  let taskIds = this.chooseTaskIdx.join(',')
                  delTask({
                    taskIds: taskIds
                  })
                    .then((res: Response) => {
                      console.log('删除任务成功', JSON.stringify(res));
                      this.chooseTaskIdx = [];
                      this.openBatchDel = false;
                      this.dialogControllerProgress.close();
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
          Image($r('app.media.manage'))
            .width(30)
            .height(30)
            .margin({ right: 8 })
            .fillColor('#000000')
            .bindMenu(
              this.TaskMenu
            )
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .width('30%')
        .position({ top: 16, right: 10 })
      }
      .width('100%')
      .height(AppStorage.get('statusBarHeight') as number - 30)
      .backgroundColor('#ffffff')
      .padding({
        left: 10,
        right: 10,
        top: 30,
        bottom: 0
      })
    }
    else if (this.currentIndex == 1) {
      Row() {
        Row() {
          Text(`${this.title}`)
            .fontColor('#000000')
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .margin({ left: 2, top: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width('30%')

        Row() {
          Text('')
            .fontColor('#000000')
            .fontSize(20)
            .textAlign(TextAlign.Start)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('40%')
        .enabled(this.openBatchDel)

        // Blank()
        Row() {
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .width('30%')
        .position({ top: 16, right: 10 })
      }
      .width('100%')
      .height(AppStorage.get('statusBarHeight') as number - 30)
      .backgroundColor('#ffffff')
      .padding({
        left: 10,
        right: 10,
        top: 30,
        bottom: 0
      })
    }
    else {
      Row() {
        Row() {
          Text('')
            .fontColor('#000000')
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .margin({ left: 2, top: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width('30%')

        Row() {
          Text('')
            .fontColor('#000000')
            .fontSize(20)
            .textAlign(TextAlign.Start)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('40%')
        .enabled(this.openBatchDel)

        // Blank()
        Row() {
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .width('30%')
        .position({ top: 16, right: 10 })
      }
      .width('100%')
      .height(AppStorage.get('statusBarHeight') as number - 30)
      .backgroundColor('#ffffff')
      .padding({
        left: 10,
        right: 10,
        top: 30,
        bottom: 0
      })
    }
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
                  taskList: this.taskList,
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