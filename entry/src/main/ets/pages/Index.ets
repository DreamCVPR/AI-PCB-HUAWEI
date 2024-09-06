import { LoadingDialog, router } from '@kit.ArkUI';
import { Settings } from './Settings'
import { Visual } from '../pages/Visual'
import { Task } from './Task'
import { NVElem, RouRefresh, Response, TaskElem } from '../common/classes'
import { TaskController } from '../controllers/TaskController'
import { delTask } from '../api/service';
import { NoticeController } from '../controllers/NoticeController';
import { noticeTime, requestTime, ThemeColor } from '../common/settings';
import { Loading } from '../components/Loading';
import { Notice } from '../components/Notice';
import { PersonalController } from '../controllers/PersonalController';


@Entry
@Component
struct Index {
  private tabController: TabsController = new TabsController()
  private taskController: TaskController = new TaskController()
  private noticeController: NoticeController = new NoticeController()
  private personalController: PersonalController = new PersonalController()
  @State showLoading: boolean = false;
  @State currentIndex: number = 0;
  @State showTask: boolean = false;
  @State helpPopup: boolean = false;
  @State title: string = '任务';
  @State openBatchDel: boolean = false;
  @State openEdit: boolean = false;
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
          this.currentIndex === this.tabs[index].num ? ThemeColor.ThemeColor: '#aaaaaa')
      Text(this.tabs[index].text)
        .fontSize(12)
        .fontWeight(500)
        .lineHeight(14)
        .fontColor(
          this.currentIndex === this.tabs[index].num ? ThemeColor.ThemeColor: '#aaaaaa'
        )
    }.width('100%')
  }

  @Builder TaskSortSubMenu() {
    Menu() {
      MenuItem({startIcon: $r('app.media.deting'), content: '检测中'})
        .onClick(() => {
          console.log('按照“检测中”状态进行查询')
          this.taskController.getTasks(Object({taskState: 2}))
        })
      MenuItem({startIcon: $r('app.media.deted'), content: '空闲'})
        .onClick(() => {
          console.log('按照“空闲”状态进行查询')
          this.taskController.getTasks(Object({taskState: 0}))
        })
      MenuItem({startIcon: $r('app.media.time'), content: '创建时间'})
        .onClick(() => {
          console.log('按照“创建时间”状态进行查询')
          this.taskController.getTasks();
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
            .fontColor(ThemeColor.NavConfig['FontColor'])
            .textShadow(ThemeColor.TextShadow)
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .margin({ left: 2, top: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width('30%')

        Row() {
          Text(this.openBatchDel ? '完成' : '')
            .fontColor(ThemeColor.NavConfig['FontColor'])
            .textShadow(ThemeColor.TextShadow)
            .fontSize(20)
            .textAlign(TextAlign.Start)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('40%')
        .enabled(this.openBatchDel)
        .onClick(() => {
          if (this.chooseTaskIdx.length > 0) {
            AlertDialog.show(
              {
                title: `已选择${this.chooseTaskIdx.length}项任务，是否删除?`,
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
                    let taskIds = this.chooseTaskIdx.join(',')
                    delTask({
                      taskIds: taskIds
                    }, `已删除${this.chooseTaskIdx.length}项任务`)
                      .then((res: Response) => {
                        if (res.status == 200) {
                          setTimeout(() => {
                            this.taskController.getTasks();
                          }, requestTime)
                        }
                        this.chooseTaskIdx = [];
                        this.openBatchDel = false;
                      })
                      .catch((err: Response) => {})
                  }
                },
                cancel: () => {

                }
              })
          }
          else {
            this.chooseTaskIdx = [];
            this.openBatchDel = false;
          }
        })

        // Blank()
        Row() {
          Image($r('app.media.manage'))
            .width(30)
            .height(30)
            .margin({ right: 8 })
            .fillColor(ThemeColor.NavConfig['FontColor'])
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
      .backgroundColor(ThemeColor.NavConfig['BackgroundColor'])
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
            .fontColor(ThemeColor.NavConfig['FontColor'])
            .textShadow(ThemeColor.TextShadow)
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .margin({ left: 2, top: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width('30%')

        Row()
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('40%')
        .enabled(this.openBatchDel)

        // Blank()
        Row()
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .width('30%')
        .position({ top: 16, right: 10 })
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
    else {
      Row() {
        Row() {
          Text(`${this.title}`)
            .fontColor(ThemeColor.NavConfig['FontColor'])
            .textShadow(ThemeColor.TextShadow)
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .margin({ left: 2, top: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width('30%')

        Row()
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('40%')
        .enabled(this.openBatchDel)

        // Blank()
        Row() {
        if (!this.openEdit) {
          Image($r('app.media.edit'))
            .width(30)
            .height(30)
            .margin({ right: 8 })
            .fillColor(ThemeColor.NavConfig['FontColor'])
            .onClick(() => {
              this.openEdit = !this.openEdit;
            })
        }
        else {
          Text('保存')
            .fontColor(ThemeColor.NavConfig['FontColor'])
            .textShadow(ThemeColor.TextShadow)
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .margin({ left: 2, top: 4 })
            .onClick(() => {
              this.personalController?.onSave();
              this.openEdit = !this.openEdit;
            })
          }
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .width('30%')
        .position({ top: 16, right: 10 })
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
                })
              } else if (item.num === 1) {
                Visual();
              } else if (item.num === 2) {
                Settings({
                  openEdit: this.openEdit,
                  personalController: this.personalController,
                });
              }
            }.width('100%')
          }.tabBar(this.TabBuilder(item.num)).flexGrow(1)
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
      Loading({ show: this.showLoading })
      Notice({noticeController: this.noticeController})
      Flex({ direction: FlexDirection.Column }) {
        // 导航栏
        this.Nav()

        // 主体
        this.Body()

      }.width('100%').height('100%')

    }
  }
}