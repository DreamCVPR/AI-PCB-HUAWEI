// 增加任务页
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { CommonConstants, Response, RouRefresh } from '../common/classes'
import { PreviewImg } from '../components/PreviewImg'
import { addTask, startDet } from '../api/service';

import util from '@ohos.util';
import image from '@ohos.multimedia.image';
import { LoadingDialog, router } from '@kit.ArkUI';
import { Empty } from '../components/Empty';
import { Loading } from '../components/Loading';
import { Notice } from '../components/Notice';
import { NoticeController } from '../controllers/NoticeController';
import { noticeTime, requestTime } from '../common/settings';

@Entry
@Component
export struct AddTask {
  @State taskName: string = '';
  @State taskDesc: string = '';
  @State imageList: Array<string> = [];
  @State imgBase64: Array<string> = [];
  @State isValidTaskName: boolean = false;
  @State isValidTaskDesc: boolean = false;
  @State openManage: boolean = false;
  @State previewImg: boolean = false;
  @State currentImg: string = '';
  @State showLoading: boolean = false;
  private noticeController: NoticeController = new NoticeController()
  @StorageLink("token") token: object | null = null;



  clear () {
    this.isValidTaskName = false;
    this.isValidTaskDesc = false;
    this.previewImg = false;
    this.taskName = '';
    this.taskDesc = '';
    this.imageList = [];
    this.imgBase64 = [];
  }

  aboutToAppear(): void {
    if (!this.token)
      router.replaceUrl({url: 'pages/Login'})
  }

  // 打开相册, 选择图像
  choiceImage () {
    let PhotoSelectOptions = new picker.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 10;
    let photoPicker = new picker.PhotoViewPicker();
    photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
      console.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
      this.imageList = PhotoSelectResult['photoUris']
    }).catch((err: string) => {
      console.error('PhotoViewPicker.select failed with err: ' + err);
    });
    } catch (err: string) {
    console.error('PhotoViewPicker failed with err: ' + err);
  }

  async transBase64() {
    let tempBase64: Array<string> = [];
    for (let i = 0; i < this.imageList.length; i++) {
      let uri: string = this.imageList[i];
      console.log('uploadImage:fileuri:' + uri);
      try {
        let fileDes = await fs.open(uri, fs.OpenMode.READ_ONLY);
        console.info("uploadImage:file fd: " + fileDes.fd);
        const imageSource = image.createImageSource(fileDes.fd);
        const imagePackerApi: image.ImagePacker = image.createImagePacker();
        let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };

        let readBuffer = await imagePackerApi.packing(imageSource, packOpts);

        let bufferArr = new Uint8Array(readBuffer)
        let help = new util.Base64Helper
        let base64 = help.encodeToStringSync(bufferArr)
        console.info("uploadImage:base is : " + base64);
        tempBase64.push(base64)
      }
      catch (err) {
        console.info("uploadImage:copy file failed with error message: " + JSON.stringify(err));
      }
    }
    this.imgBase64 = [...tempBase64]
  }

  // 返回前一页
  back (): void {
    console.log('返回前一页')
    let paramInfo: RouRefresh = {
      refresh: true
    }
    router.back({url: 'pages/Index', params: paramInfo})
  }

  // 提交任务
  async confirm() {
    this.showLoading = true;
    await this.transBase64();
    let fileNames: Array<string> = [];
    for (let i = 0; i < this.imageList.length; i++) {
      let fileName: string = this.imageList[i].substring(this.imageList[i].lastIndexOf("\/")+1);
      fileNames.push(fileName);
    }
    console.log('imageList', JSON.stringify(this.imageList))
    console.log('fileNames', JSON.stringify(fileNames))
    addTask({
      'task_name': this.taskName,
      'task_desc': this.taskDesc,
      'files': this.imgBase64,
      'fileNames': fileNames
    })
      .then((res: Response) => {
        this.showLoading = false;
        if (res.status == 200) {
          this.noticeController.success('新建任务成功');
          setTimeout(() => {
            this.noticeController.close();
            this.clear();
            this?.back();
          }, requestTime)
        }
        else {
          this.noticeController.fail('新建任务失败');
          setTimeout(() => {
            this.noticeController.close();
          }, noticeTime)
        }
      })
      .catch((err: Response) => {
        this.showLoading = false;
        this.noticeController.fail('新建任务失败');
        setTimeout(() => {
          this.noticeController.close();
        }, noticeTime)
      })

  }
  @Builder Nav(): void {
    Row() {
      Row() {
        Image($r('app.media.left_arrow'))
          .width(24)
          .height(24)
          .margin({ left: 8 })
          .fillColor('#000000')
      }
      .onClick(() => {
        this.back();
      })

      Column() {
        Text('创建检测任务')
          .fontSize(18)
          .width('78%')
          .textAlign(TextAlign.Center)
      }
      .margin({ left: 20 })
    }
    .padding({ top: 36, left: 6, right: 10 })
    .height(AppStorage.get('statusBarHeight') as number - 40)
    .width('100%')
    .zIndex(99)
  }

  @Builder Body(): void {
    RelativeContainer() {
       this.Nav()

      Column() {
        Column() {
          Column() {
            Row() {
              Column() {
                Image($r('app.media.task_name'))
                  .width(24)
                  .height(24)
                  .margin({ top: 10, right: 8 })
              }
              .height('100%')

              Column() {
                TextInput({ placeholder: '请输入任务名', text: this.taskName })
                  .height(40).width('100%')
                  .onChange((value: string) => {
                    if (value.length > 16)
                      this.isValidTaskName = false; else
                      this.isValidTaskName = true;
                    this.taskName = value
                  })
                  .onCopy((value: string) => {
                    this.taskName = value
                  })
                Text('任务名称取值范围为1至16位')
                  .fontColor('rgb(180, 180, 180)')
                  .fontSize(12)
                  .width('100%')
                  .margin({ left: 30 })
              }
            }
            .height(60)

            Divider().strokeWidth(1).margin({ left: 50 })
          }


          Column() {
            Row() {
              Column() {
                Image($r('app.media.task_desc'))
                  .width(24)
                  .height(24)
                  .margin({ top: 10, right: 8 })
              }
              .height('100%')

              Column() {
                TextArea({ placeholder: '请输入任务描述', text: this.taskDesc })
                  .height(60)
                  .width('100%')
                  .textOverflow(TextOverflow.Ellipsis)
                  .onChange((value: string) => {
                    if (value.length > 64)
                      this.isValidTaskDesc = false; else
                      this.isValidTaskDesc = true;
                    this.taskDesc = value
                  })
                Text('任务描述取值范围为1至64位')
                  .fontColor('rgb(180, 180, 180)')
                  .fontSize(12)
                  .width('100%')
                  .margin({ left: 30 })
              }
            }

            Divider().strokeWidth(1).margin({ left: 50 })
          }
          .height(80)

          Flex() {
            Row() {
              Image($r('app.media.image')).width(24).height(24).margin({ right: 20 })
              Button('上传图像')
                .onClick(() => {
                  console.log('上传图像');
                  this.choiceImage();
                })
                .align(Alignment.Start)
                .enabled(!this.previewImg)
              Blank()
              Text(this.openManage ? '退出管理' : '管理')
                .onClick(() => {
                  this.openManage = !this.openManage
                })

            }
            .width('100%')
          }
          .width('100%')
          .margin({ top: 12 })

        }
        .margin({
          top: 20,
          left: 26,
          right: 26,
          bottom: 5
        })

        Column() {
          if (this.imageList.length === 0) {
            Empty()
          }
          else {
            List({ space: 16, initialIndex: 0 }) {
              ForEach(this.imageList, (item: string) => {
                ListItem() {
                  Row() {
                    Image(item)
                      .width(28)
                      .height(28)
                    Row() {
                        Text(item.substring(item.lastIndexOf("\/") + 1))
                          .fontSize(16)
                          .textAlign(TextAlign.Start)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .onClick(() => {
                            this.currentImg = item;
                            this.previewImg = !this.previewImg;
                          })
                          .maxLines(1)
                          .height('100%')
                          .width('80%')

                      if (this.openManage) {
                        Column() {
                          Image($r('app.media.delete2'))
                            .width(24)
                            .height(24)
                            .onClick(() => {
                              let tempImage = [...this.imageList];
                              let index = tempImage.indexOf(item);
                              if (index > -1)
                                tempImage.splice(index, 1);
                              this.imageList = [...tempImage];
                            })
                            .margin({ left: 16, top: 4 })
                        }
                        .height('100%')
                      }
                    }
                    .margin({ left: 22, right: 18 })
                    .width('80%')
                    .alignItems(VerticalAlign.Center)
                  }
                }
                .width('100%')
                .height(30)
              })
            }
            .margin({
              top: 12,
              left: 24,
              right: 20,
              bottom: 12
            })
            .alignListItem(ListItemAlign.Start)
            .enabled(!this.previewImg)
            // .width('100%')
          }
          // .divider({ strokeWidth: 2, startMargin: 20, endMargin: 20, color: 'rgb(230, 230, 230)' })
        }
        .height('60%')

        Flex({ justifyContent: FlexAlign.SpaceAround }) {
          Button('取消', { type: ButtonType.Normal, stateEffect: true })
            .onClick(() => {
              this.clear();
              this.back();
            })
            .fontColor(Color.Black)
            .backgroundColor('#ffffff')
            .height(36)
            .width(120)
            .enabled(!this.previewImg)
            .borderWidth(1)
            .borderRadius(4)

          Button('确定',
            { type: ButtonType.Normal, stateEffect: this.isValidTaskName && this.isValidTaskDesc ? true : false })
            .onClick(() => {
              if (this.isValidTaskName && this.isValidTaskDesc) {
                this.confirm();
              }
            })
            .enabled(!this.previewImg && this.isValidTaskName && this.isValidTaskDesc)
            .backgroundColor('#0A59F7')
            .borderRadius(4)
            .height(36)
            .width(120)
        }
      }
      .margin({ top: 80 })
    }.enabled(!this.previewImg)
    .height('100%')
  }

  build() {

    Flex({direction: FlexDirection.Column}) {
      Loading({ show: this.showLoading })
      Notice({noticeController: this.noticeController})
      Stack({alignContent: Alignment.TopStart}) {
        this.Body()

        if (this.previewImg && this.currentImg != '') {
          PreviewImg({url: this.currentImg})
            .onClick(() => {
              console.log('关闭预览图像')
              this.previewImg = !this.previewImg;
              this.currentImg = ''
            })
        }
      }
      .height('100%')
    }
    .height('100%')
  }
}