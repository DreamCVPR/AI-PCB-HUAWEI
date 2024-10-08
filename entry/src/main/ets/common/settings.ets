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

@Builder
export function DisableBackground(color: ResourceColor, opacity: number = 0.3, condition: boolean = true) {
  Row() {}.backgroundColor(color).opacity(opacity).width("100%").height("100%")
}

interface RadialGradient {
  center: [
    Length,
    Length
  ];
  radius: number | string;
  colors: Array<[
    ResourceColor,
    number
  ]>;
  repeating?: boolean;
}

export class ThemeColor {
  static ThemeColor = "#000000"
  static NavConfig: object = Object({
    BackgroundColor: "#ffffff",
    FontColor: '#000000'
  })
  static LoadingColor = "#99017BBE"
  static FontColor = "#202020"
  static CaretColor = "#95000000"
  static BackgroundColor = "#DCDCDC"
  static ButtonColor = "rgb(49,94,251)"
  static ButtonFontColor = "#ffffff"
  static CheckBoxSelectColor = "#003edc"
  static CheckBoxUnSelectedColor = "#ffffff"
  static ItemSelectColor = "#CBE5FE"
  static TextShadow = new _ShadowOptions(0.2, undefined, "rgba(0, 0, 0, 0.1)", 2, 2, undefined)
  static Shadow = new _ShadowOptions(25, undefined, "rgba(0, 0, 0, 0.2)", undefined, undefined, undefined)
  static DisableButtonRadialGradient(color: string, condition: boolean) {
    return ({
      center: ["50%", "50%"],
      radius: "200%",
      colors: [[color, 0.0], [condition ? Color.White : color, 1.0]]
    } as RadialGradient)
  }
}