
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
  countDetectImg: number = 0
  countAllImg: number = 0
  taskCoverImg: string = ''
  countDefect: number = 0
  cateDefect: Array<string> = []
  colorDefect: Array<string> = []

  constructor(taskId: number, taskName: string, taskDesc: string, harmonyUserId: string,
    taskState: number, gmtCreate: string, countDetectImg: number, countAllImg: number,
    taskCoverImg: string, countDefect: number, cateDefect: Array<string>, colorDefect: Array<string>) {
      this.taskId = taskId;
      this.taskName = taskName;
      this.taskDesc = taskDesc;
      this.harmonyUserId = harmonyUserId;
      this.taskState = taskState;
      this.gmtCreate = gmtCreate;
      this.countDetectImg = countDetectImg;
      this.countAllImg = countAllImg;
      this.taskCoverImg = taskCoverImg
      this.countDefect = countDefect;
      this.cateDefect = cateDefect;
      this.colorDefect = colorDefect;
  }
}

// 首页任务刷新参数
export class RouRefresh {
  refresh: boolean = false;
}

// 用户个人信息类
export class UserInfo {
  harmonyUserId?: string
  gmtCreate?: string
  openId?: string
  unionId?: string
  userImg?: string
  userName?: string
  userPhone?: string
  loginName?: string
  loginPwd?: string
  token?: string
  userInfo?: string
}