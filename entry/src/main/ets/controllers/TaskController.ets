import { Task } from '../pages/Task'

// 用于Index父组件调用Task子组件, 增加任务后重新刷新
export class TaskController {
  private taskComponent: Task | null = null;

  attach(component: Task): void {
    this.taskComponent = component
  }

  public getTasks(params: object | null = null): void  {
    if (this.taskComponent)
      this.taskComponent.getTasks(params);
  }

  public setParams(params: object): void  {
    if (this.taskComponent)
      this.taskComponent.setParams(params);
  }
}