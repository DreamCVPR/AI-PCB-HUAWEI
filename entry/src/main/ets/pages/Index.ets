import router from '@ohos.router';
import { Detection } from '../pages/Detection'
import { Visual } from '../pages/Visual'
import { Task } from '../components/task'
import { TaskDialog } from '../components/TaskDialog'
import { NVElem } from '../common/classes'
import { login } from '../api/account';

// 初始化存储的token
PersistentStorage.persistProp('token', '')


@Entry
@Component
struct Index {
  private controller: TabsController = new TabsController()
  @State currentIndex: number = 0;
  @State showTask: boolean = false;
  @State Build: Array<NVElem> = [
    {
      text: '首页',
      num: 0,
      init: 'app.media.home',
      selected: 'app.media.home_selected',
      page: 'pages/Index',
    },
    {
      text: '检测',
      num: 1,
      init: 'app.media.det',
      selected: 'app.media.det_selected',
      page: 'pages/Detection',
    },
    {
      text: '可视化',
      num: 2,
      init: 'app.media.vis',
      selected: 'app.media.vis_selected',
      page: 'pages/Visual',
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



  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        Row() {
          Text('检测任务')
            .fontColor('#ffffff')
            .fontSize(20)
            .fontWeight(700)
            .textAlign(TextAlign.Start)
            .margin({ left: 2 })
          Blank()
          TaskDialog()
        }
        .width('100%')
        .height(60)
        .backgroundColor('#3022CF')
        .padding({
          left: 10,
          right: 10,
          top: 5,
          bottom: 5
        })

        Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
          ForEach(this.Build, (item: NVElem) => {
            TabContent() {
              Column() {
                if (item.num === 0) {
                  Task();
                } else if (item.num === 1) {
                  Detection();
                } else if (item.num === 2) {
                  Visual();
                }
              }.width('100%')
            }.tabBar(this.TabBuilder(item.num))
          })
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

      }.width('100%').height('100%')

    }
  }
}