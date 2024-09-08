import { Visual } from '../pages/Visual'

// 用于Index父组件调用Chart子组件, 增加任务后重新刷新
export class ChartController {
  private chartComponent: Visual | null = null;

  attach(component: Visual): void {
    this.chartComponent = component
  }

  public refresh(params: object | null = null): void  {
    if (this.chartComponent)
      this.chartComponent.refresh();
  }
}