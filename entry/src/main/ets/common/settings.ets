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

class _ShadowOptions implements  ShadowOptions {
  radius: number | Resource = 5
  type?: ShadowType | undefined
  color?: string | Resource | Color | undefined
  offsetX?: number | Resource | undefined
  offsetY?: number | Resource | undefined
  fill?: boolean | undefined

  constructor(radius: number | Resource, type: ShadowType | undefined, color: string | Resource | Color | undefined,
    offsetX: number | Resource | undefined, offsetY: number | Resource | undefined, fill: boolean | undefined) {
    this.radius = radius
    this.type = type
    this.color = color
    this.offsetX = offsetX
    this.offsetY = offsetY
    this.fill = fill
  }
}

export class ThemeColor {
  static ThemeColor = "#000000"
  static NavConfig: object = Object({
    BackgroundColor: "#ffffff",
    FontColor: '#000000'
  })
  static LoadingColor = "#906F3E35"
  static FontColor = "#202020"
  static CaretColor = "#95000000"
  static BackgroundColor = "#DCDCDC"
  static ButtonColor = "#786ef2"
  static ButtonFontColor = "#ffffff"
  static CheckBoxSelectColor = "#F64639"
  static CheckBoxUnSelectedColor = "#ffffff"
  static DisableColor(color: string) { return "#50"+color.replace("#", "") }
  static TextShadow = new _ShadowOptions(0.2, undefined, "rgba(0, 0, 0, 0.1)", undefined, 2, undefined)
  static Shadow = new _ShadowOptions(25, undefined, "rgba(0, 0, 0, 0.2)", undefined, undefined, undefined)
}