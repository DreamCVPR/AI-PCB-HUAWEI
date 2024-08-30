// 用于Index父组件调用Task子组件, 增加任务后重新刷新
import { Task } from '../pages/Task'

export class TaskController {
  private taskComponent: Task | null = null;

  attach(component: Task): void {
    this.taskComponent = component
  }

  public getTasks(): void  {
    if (this.taskComponent)
      this.taskComponent.getTasks();
  }
}