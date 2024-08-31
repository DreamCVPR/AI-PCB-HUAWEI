import router from '@ohos.router';
import { Settings } from './Settings'
import { Visual } from '../pages/Visual'
import { Task } from './Task'
import { TaskDialog } from '../components/TaskDialog'
import { NVElem, CommonConstants } from '../common/classes'
import { TaskController } from '../controllers/TaskController'
import { TaskDialogController } from '../controllers/TaskDialogController'
import { login } from '../api/account';

// 初始化存储的token
PersistentStorage.persistProp('token', '')


@Entry
@Component
struct Index {
  private tabController: TabsController = new TabsController()
  private taskController: TaskController = new TaskController()
  @State currentIndex: number = 0;
  @State showTask: boolean = false;
  @StorageLink("token") token: string = "";
  @State Build: Array<NVElem> = [
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

  @Builder TabBuilder(index: number) {
    Column() {
      Image(this.currentIndex === this.Build[index].num ? $r(this.Build[index].selected) : $r(this.Build[index].init))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Contain)
      Text(this.Build[index].text)
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width('100%')
  }

  aboutToAppear(): void {
    login()
      .then((res: object) => {
        console.log("获取任务成功:"+  JSON.stringify(res));
        this.token = res["result"]
        // PersistentStorage.persistProp('token', this.token)
      })
      .catch((err: object) => {
        console.log("获取任务失败:" + JSON.stringify(err))
      })
  }

  // 用于子组件调用, 出发父组件和其他组件通信, 刷新
  onRefresh () {
    console.log('子组件触发刷新');
    this.taskController.getTasks();
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        Row() {
          Flex() {
            Text('检测任务')
              .fontColor('#ffffff')
              .fontSize(20)
              .fontWeight(700)
              .textAlign(TextAlign.Start)
              .margin({ left: 2 })
            Blank()
            TaskDialog({
              refresh: this.onRefresh.bind(this)
            })
          }
        }
        .width('100%')
        .height(CommonConstants.STATUS_BAR_HEIGHT - 10)
        .backgroundColor('rgb(130, 178, 154)')
        .padding({
          left: 10,
          right: 10,
          top: 30,
          bottom: 0
        })

        Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
          if (this.token) {
            ForEach(this.Build, (item: NVElem) => {
              TabContent() {
                Column() {
                  if (item.num === 0) {
                    Task({
                      taskController: this.taskController
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
        }
        .onChange((index: number) => {
          this.currentIndex = index
        })
        .animationDuration(0)
        .barWidth('100%')
        // .scrollable(false)
        .barMode(BarMode.Fixed)
        .vertical(false)
        .barHeight(56)
        .margin({bottom:16})

      }.width('100%').height('100%')

    }
  }
}