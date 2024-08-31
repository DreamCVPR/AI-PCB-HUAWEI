import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { login } from '../api/account';
import { Response } from '../common/classes'
import { addTask, startDet } from '../api/service';

import util from '@ohos.util';
import image from '@ohos.multimedia.image';



@CustomDialog
export struct TaskDetail {
  // 用于父子组件双向通信
  @Link taskName: string
  @Link taskDesc: string
  @Link imageList: Array<string>

  @Link isValidTaskName: boolean
  @Link isValidTaskDesc: boolean
  @Link isInit: boolean

  inputNameController: TextInputController = new TextInputController();
  inputDescController: TextInputController = new TextInputController();
  // 指向自己的controller
  controller?: CustomDialogController;

  // 定义回调函数
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  // 打开相册, 选择图像
  choiceImage () {
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 5;
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

  build() {
    Column() {
      Text('新建检测任务').fontSize(20).margin({ top: 10, bottom: 20 })

      Column() {
        Column () {
          Column() {
            TextInput({ placeholder: '请输入任务名', text: this.taskName, controller: this.inputNameController })
              .height(40).width('80%')
              .onChange((value: string) => {
                if (value.length > 16)
                  this.isValidTaskName = false;
                else
                  this.isValidTaskName = true;
                this.taskName = value
              })
              .onCopy((value: string) => {
                this.taskName = value
              })
              Text(this.isValidTaskName ? ' ' : '请输入一个1至16位的任务名称')
                .fontColor('rgb(239, 065, 067)')
                .fontSize(12)
                .width('80%')
                .margin({left: 30})
            }
          .margin({bottom: 12})

          Column() {
            TextArea({ placeholder: '请输入任务描述', text: this.taskDesc, controller: this.inputNameController })
              .height(60)
              .width('80%')
              .textOverflow(TextOverflow.Ellipsis)
              .onChange((value: string) => {
                if (value.length > 64)
                  this.isValidTaskDesc = false;
                else
                  this.isValidTaskDesc = true;
                this.taskDesc = value
              })

            Text(this.isValidTaskDesc ? ' ' : '请输入一个1至64位的任务描述')
              .fontColor('rgb(239, 065, 067)')
              .fontSize(12)
              .width('80%')
              .margin({ left: 30 })
          }
          .margin({bottom: 12})

          Flex() {
            Button('上传图像')
              .onClick(() => {
                console.log('上传图像');
                this.choiceImage();
              })
              .margin({ top: 10 })
              .align(Alignment.Start)
          }
          .width('80%')
        }

        List({space: 20, initialIndex: 0}) {
          ForEach(this.imageList, (item: string) => {
              ListItem() {
                Row() {
                  Flex() {
                    Text(item.substring(item.lastIndexOf("\/") + 1))
                      .width('80%').fontSize(14)
                      .textAlign(TextAlign.Start)
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
                  }
                  .margin({ left: 22, right: 18 })
                  .width('100%')
                }
              }
              .width('100%')
              .height(30)
          })
        }
        .margin(20)
        .alignListItem(ListItemAlign.Start)

        Blank()
        Flex({ justifyContent: FlexAlign.SpaceAround }) {
          Button('取消', {type: ButtonType.Normal, stateEffect: true})
            .onClick(() => {
              this.controller?.close();
              this.cancel()
            })
            .fontColor(Color.Black)
            .backgroundColor('#ffffff')
            .borderWidth(1)
            .borderColor('#ffffff')
            .borderRadius(4)
            .borderRadius(4)
            .height(36)
            .width(120)

          Button('确定',
            {type: ButtonType.Normal, stateEffect: this.isValidTaskName && this.isValidTaskDesc ? true: false})
            .onClick(() => {
              // 再次判断下
              if (this.taskName.length > 0 && this.taskName.length <= 16)
                this.isValidTaskName = true;
              else
                this.isValidTaskName = false;

              if (this.taskDesc.length > 0 && this.taskDesc.length <= 64)
                this.isValidTaskDesc = true;
              else
                this.isValidTaskDesc = false;


              if (this.isValidTaskName && this.isValidTaskDesc && this.controller != undefined) {
                this.isValidTaskName = true;
                this.isValidTaskDesc = true;
                this.confirm();
                this.controller?.close()
              }
            })
            .opacity(this.isValidTaskName && this.isValidTaskDesc ? 1.0: 0.4)
            .backgroundColor('#0A59F7')
            .borderRadius(4)
            .height(36)
            .width(120)
        }
      }
      .height('80%')

    }.borderRadius(4)
    .height('100%')
  }
}

@Entry
@Component
export struct TaskDialog {
  @State taskName: string = '';
  @State taskDesc: string = '';
  @State imageList: Array<string> = ['1.jpg', '2.jpg', '3.jpg'];
  @State imgBase64: Array<string> = [];
  @State isValidTaskName: boolean = true;
  @State isValidTaskDesc: boolean = true;
  @State isInit: boolean = true;

  refresh: () => void = () => {}

  @StorageLink('token') token: string = '';

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TaskDetail({
      cancel: this.onCancel.bind(this),
      confirm: this.onAccept.bind(this),
      taskName: this.taskName,
      taskDesc: this.taskDesc,
      imageList: this.imageList,
      isValidTaskName: this.isValidTaskName,
      isValidTaskDesc: this.isValidTaskDesc,
      isInit: this.isInit,
    }),
    cancel: this.exitApp.bind(this),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    gridCount: 10,
    customStyle: false
  })


  // 在自定义组件即将析构销毁时销毁组件

  clear () {
    this.taskName = '';
    this.taskDesc = '';
    this.imageList = [];
    this.imgBase64 = [];
    this.isValidTaskName = true;
    this.isValidTaskDesc = true
    // this.dialogController = null;
  }
  aboutToDisappear() {
    this.clear()
  }

  onCancel() {
   this.clear()
  }

  async transBase64() {
    for (let i = 0; i < this.imageList.length; i++) {
      let uri: string = this.imageList[0];
      console.log('uploadImage:fileuri:' + uri);
      let tempBase64: Array<string> = [];
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
        this.imgBase64 = [...tempBase64]
      }
      catch (err) {
        console.info("uploadImage:copy file failed with error message: " + JSON.stringify(err));
      }
    }
}


  // 增加任务(确定回调), 文件转base64
  async onAccept() {
    await this.transBase64();
    let fileNames: Array<string> = [];
    for (let i = 0; i < this.imageList.length; i++) {
      let fileName: string = this.imageList[i].substring(this.imageList[i].lastIndexOf("\/")+1);
      fileNames.push(fileName);
    }
    console.log('fileNames', JSON.stringify(fileNames))
    addTask({
      'task_name': this.taskName,
      'task_desc': this.taskDesc,
      'files': this.imgBase64,
      'fileNames': fileNames
    })
      .then((data: Response) => {
        console.log("增加任务成功:"+  JSON.stringify(data));
        this?.refresh();
      })
      .catch((err: Response) => {
        console.log("增加任务失败:" + JSON.stringify(err))
      })

    this.clear();
  }

  exitApp() {
    this.clear();
    console.info('Click the callback in the blank area')
  }

  build() {
    Column() {
      Image($r('app.media.add2'))
        .width(26)
        .height(26)
        .onClick(() => {
          this.dialogController?.open();
        })

    }.margin({right: 4})
  }
}