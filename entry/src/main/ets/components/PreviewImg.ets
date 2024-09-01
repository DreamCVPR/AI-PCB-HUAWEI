// 预览图片组件

@Entry
@Component
export struct PreviewImg {
  public url: string = ''

  @Builder Mask(opacity: number = 0.95, zIndex: number = 998) {
    Row() {}.height("100%").width("100%").backgroundColor(Color.Gray).opacity(opacity).zIndex(zIndex)
  }
  @Builder previewImg(): void {
    Stack() {
      this.Mask()
      Image(this.url)// 直接加载网络地址，请填写一个具体的网络图片地址
        .alt($r('app.media.load_img'))
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.ScaleDown)
        .zIndex(999)
        .onClick((e)=>{
          console.log("this.originImgUrl："+ this.url)
        })
        .position({ x: '0', y: '0' })
    }.zIndex(999)
  }

  build() {
    Stack() {
      this.previewImg();
    }
  }

}
