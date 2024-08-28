import router from '@ohos.router';
// import store from '../utils/store'


class NVElem {
  text: string = ''
  num: number = 0
}

@Entry
@Component
struct Index {
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  @State currentIndex: number = 0
  @State Build: Array<NVElem> = [
    {
      text: 'home',
      num: 0
    },
    {
      text: 'det',
      num: 1
    },
    {
      text: 'vis',
      num: 2
    }
  ]

  @Builder NavigationTitle() {
    Column() {
      Text('质造智控：AI助力的精密质检')
        .fontColor('#182431')
        .fontSize(25)
        .lineHeight(41)
        .fontWeight(700)
        .margin({top: -20})
        .textAlign(TextAlign.Center)
        .width('100%')
      Text('Mamba back again')
        .fontColor('#182431')
        .fontSize(14)
        .lineHeight(19)
        .opacity(0.4)
        .margin({ top: 2, left: 20, bottom: 20 })
    }.alignItems(HorizontalAlign.Start)
  }

  @Builder NavigationMenus() {
    Row() {
      Image('common/navigation_icon1.svg')
        .width(24)
        .height(24)
      Image('common/navigation_icon1.svg')
        .width(24)
        .height(24)
        .margin({ left: 24 })
      Image('common/navigation_icon2.svg')
        .width(24)
        .height(24)
        .margin({ left: 24 })
    }
  }

  @Builder NavigationToolbar() {
    Row() {
      ForEach(this.Build, (item: NVElem) => {
        Column() {
          Image(this.currentIndex == item.num ? 'common/public_icon_selected.svg' : 'common/public_icon.svg')
            .width(24)
            .height(24)
          Text(item.text)
            .fontColor(this.currentIndex == item.num ? '#007DFF' : '#182431')
            .fontSize(10)
            .lineHeight(14)
            .fontWeight(500)
            .margin({ top: 3 })
        }.width(104).height(56)
        .onClick(() => {
          this.currentIndex = item.num
        })
      })
    }.margin({ left: 24 })
  }

  build() {
    Column() {
      Navigation() {
        TextInput({ placeholder: 'search...' })
          .width('90%')
          .height(40)
          .backgroundColor('#FFFFFF')
          .margin({ top: 8 })

        List({ space: 12, initialIndex: 0 }) {
          ForEach(this.arr, (item: NVElem) => {
            ListItem() {
              Text('' + item)
                .width('90%')
                .height(72)
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .fontSize(16)
                .fontWeight(500)
                .textAlign(TextAlign.Center)
            }.editable(true)
          })
        }
        .height(324)
        .width('100%')
        .margin({ top: 12, left: '10%' })
      }
      .title(this.NavigationTitle)
      .menus(this.NavigationMenus)
      .titleMode(NavigationTitleMode.Full)
      .toolBar(this.NavigationToolbar)
      .hideTitleBar(false)
      .hideToolBar(false)
      .onTitleModeChange((titleModel: NavigationTitleMode) => {
        console.info('titleMode' + titleModel)
      })
    }.width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}