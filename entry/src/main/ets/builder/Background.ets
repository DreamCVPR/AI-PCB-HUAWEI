import { common } from '@kit.AbilityKit';


function getRandomFileName(context: common.Context) {
  const imgNameList = context.resourceManager.getRawFileListSync("background")
  return imgNameList[Math.floor((Math.random()*imgNameList.length))]
}

function getFileName(context: common.Context, key: string): string {
  try {
    if (!key) return getRandomFileName(context)
    let backgroundFileName: object | undefined = AppStorage.get('backgroundFileName');
    if (!backgroundFileName) backgroundFileName = new Object()
    if (!backgroundFileName[key]) backgroundFileName[key] = getRandomFileName(context)
    PersistentStorage.persistProp('backgroundFile', backgroundFileName)
    return backgroundFileName[key]
  } catch (err) {
    console.error(`getRawFileListSync failed, error code: ${JSON.stringify(err)}`);
    return "0.jpg"
  }
}

@Builder
export function Background(context: common.Context, key: string = "", opacity: number = 0.3) {
  Row() {
    Image($rawfile(`background/${getFileName(context, key)}`))
      .objectFit(ImageFit.Cover)
      .width("100%")
      .height("100%")
  }
  .opacity(opacity)
  .width("100%")
  .height("100%")
}
