import { Task } from '../pages/Task'

export class TaskDialogController {
  private dialogComponent: Task | null = null;

  attach(component: Task): void {
    this.dialogComponent = component
  }
}