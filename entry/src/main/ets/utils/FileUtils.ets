import { http } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager, common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import picker from '@ohos.file.picker';

import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import util from '@ohos.util';


export class FileUtils {
  private PERMISSIONS: Array<Permissions> = ['ohos.permission.INTERNET', "ohos.permission.WRITE_IMAGEVIDEO"];
  private imgCount: number = 0
  private saveCount: number = 0

  async saveImg(imgUrlList: Array<string>) {
    this.imgCount = imgUrlList.length
    await this.grantPermission().then(async () => {
      imgUrlList.forEach((url: string, index: number) => {
        this.loadImageWithUrl(url, index+1)
      });
    }).catch((err: BusinessError) => {
      console.info(`grantPermission faild  ${JSON.stringify(err.code)}`);
    })
  }

  // 打开相册, 选择图像([imgBase64List, imgNameList])
  async chooseImage(): Promise<string[][]> {
    try {
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 10;
      let photoPicker = new picker.PhotoViewPicker();
      return await photoPicker.select(PhotoSelectOptions).then(async (PhotoSelectResult) => {
        console.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
        return [await this.transBase64(PhotoSelectResult['photoUris']), PhotoSelectResult['photoUris'].map(v=>v.substring(v.lastIndexOf("\/")+1))]
      }).catch((err: string) => {
        console.error('PhotoViewPicker.select failed with err: ' + err);
        return [[],[]]
      })
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error('PhotoViewPicker failed with err: ' + JSON.stringify(err));
      return [[],[]]
    }
  }

  /*******************************以上为工具方法，以下方法仅服务于本文件*******************************/

  private async grantPermission(): Promise<boolean> {
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(
          bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
        );
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      let tokenId = appInfo.accessTokenId;
      let atManager = abilityAccessCtrl.createAtManager();
      let pems: Array<Permissions> = [];
      for (let i = 0; i < this.PERMISSIONS.length; i++) {
        let state = await atManager.checkAccessToken(tokenId, this.PERMISSIONS[i]);
        if (state !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          pems.push(this.PERMISSIONS[i]);
        }
      }
      if (pems.length > 0) {
        let ctx = getContext(this) as common.UIAbilityContext
        let result: PermissionRequestResult = await atManager.requestPermissionsFromUser(ctx, pems);
        let grantStatus: Array<number> = result.authResults;
        let length: number = grantStatus.length;
        for (let i = 0; i < length; i++) {
          if (grantStatus[i] !== 0) {
            return false;
          }
        }
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  private loadImageWithUrl(url: string, index: number) {
    // 使用request下载图片并在回调函数中保存图片到相册
    http.createHttp().request(url,
      {
        method: http.RequestMethod.GET,
        connectTimeout: 60000,
        readTimeout: 60000
      },
      async (error: BusinessError, data: http.HttpResponse) => {
        if (error) {
          promptAction.showToast({ message: `图片${index}下载失败，${error.message}` });
        } else {
          if (http.ResponseCode.OK === data.responseCode) {
            let imageBuffer: ArrayBuffer = data.result as ArrayBuffer;
            try {
              // 获取相册路径
              const context = getContext(this);
              let helper = photoAccessHelper.getPhotoAccessHelper(context);
              let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
              let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
              // 写入文件
              await fileIo.write(file.fd, imageBuffer);
              // 关闭文件
              await fileIo.close(file.fd);
              if (++this.saveCount == this.imgCount) {
                promptAction.showToast({ message: `图片保存成功` });
              }
            } catch (error) {
              promptAction.showToast({ message: `图片${index}保存失败，${JSON.stringify(error)}` });
            }
          } else {
            promptAction.showToast({ message: `图片${index}下载失败，未知异常` });
          }
        }
      })
  }

  private async transBase64(imageList: Array<string>) {
    let tempBase64: Array<string> = [];
    for (let i = 0; i < imageList.length; i++) {
      let uri = imageList[i];
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
    return [...tempBase64]
  }
}