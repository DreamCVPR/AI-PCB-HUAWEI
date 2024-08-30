
// 全局变量
export class CommonConstants {
  static STATUS_BAR_HEIGHT: number = 0;
}

// 响应体对象
export class Response {
  result: Array<Map<string, string | number>>
  message?: string
  status?: number

  constructor(result: Array<Map<string, string | number>>, message: string, status: number) {
    this.result = result
    this.message = message
    this.status = status
  }
}


// tab对象
export class NVElem {
  text: string = ''
  num: number = 0
  init: string = ''
  selected: string = ''
  page: string = ''
}

// task对象
export class TaskElem {
  taskId: number = 0
  taskName: string = ''
  taskDesc: string = ''
  harmonyUserId: string = ''
  taskState: number = 0
  gmtCreate: string = ''

  constructor(taskId: number, taskName: string, taskDesc: string, harmonyUserId: string,
    taskState: number, gmtCreate: string) {
    this.taskId = taskId;
    this.taskName = taskName;
    this.taskDesc = taskDesc;
    this.harmonyUserId = harmonyUserId;
    this.taskState = taskState;
    this.gmtCreate = gmtCreate;
  }
}
