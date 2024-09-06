import { Settings } from '../pages/Settings'

// 用于Index父组件调用Task子组件, 增加任务后重新刷新
export class PersonalController {
  private taskComponent: Settings | null = null;

  attach(component: Settings): void {
    this.taskComponent = component
  }

  public onSave(): void  {
    if (this.taskComponent)
      this.taskComponent.onSave();
  }
}