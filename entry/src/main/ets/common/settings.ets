// 请求加载时长
export const requestTime: number = 500

// 消息提示时长
export const noticeTime: number = 1500

// 瑕疵类型
export const cateFlowMap: object = new Object({
  "mouse_bite": "鼠咬",
  "spur": "毛刺",
  "spurious_copper": "伪铜",
  "open_circuit": "开路",
  "short": "短路",
})

// 瑕疵类型对应的颜色
export const colorFlowMap: object = new Object({
  "mouse_bite": "rgb(042, 157, 142)",
  "spur": "rgb(233, 196, 107)",
  "spurious_copper": "rgb(242, 162, 097)",
  "open_circuit": "rgb(230, 111, 081)",
  "short": "rgb(038, 070, 083)"
})