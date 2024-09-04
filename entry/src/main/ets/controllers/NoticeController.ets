import { Notice } from '../components/Notice'


// 消息框控制器, 控制不同消息提示
export class NoticeController {
  private noticeComponent: Notice | null = null;

  attach(value: Notice) {
    this.noticeComponent = value
  }

  public success(value: string) {
    if (this.noticeComponent)
      this.noticeComponent.success(value);
  }

  public fail(value: string) {
    if (this.noticeComponent)
      this.noticeComponent.fail(value);
  }

  public warning(value: string) {
    if (this.noticeComponent)
      this.noticeComponent.warning(value);
  }

  public close(): void {
    this.noticeComponent?.close()
  }

}