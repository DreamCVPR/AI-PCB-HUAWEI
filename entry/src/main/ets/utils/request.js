import http from '@ohos.net.http'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction';

// 后端API地址
export const baseUrl = 'http://192.168.0.114:7777/api'

// 通用请求实现
export async function requests(options) {

    let {url, method, data, message} = options
    if (url.substring(0, 4) !== "http") {
        url = baseUrl + url
    }
    if (!data)
        data = {}

    let httpRequest = http.createHttp();
    let header = {
        'Content-Type': 'application/json;charset=UTF-8'
    }

    const token = AppStorage.get('token')
    if (token) header['Access-Token'] = token

    return new Promise((resolve, reject) => {

        httpRequest.request(
            url,
            {
                method: method.toUpperCase(), // 可选，默认为http.RequestMethod.GET
                header: header,
                extraData: data,
                connectTimeout: 60000, // 可选，默认为60000ms
                readTimeout: 60000, // 可选，默认为60000ms
                // usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
            }, (err, data) => {
            if (!err) {
                const res = JSON.parse(data.result)
                if (res["status"] == "200") {
                    if (message) {
                        promptAction.showToast({ message: message, duration: 3000 });
                    }
                    resolve(res)
                } else {
                    promptAction.showToast({ message: res["message"], duration: 3000 });
                    if (data.header["token_status"] !== "1") {
                        AppStorage.set('token', '');
                        router.clear()
                        if (router.getState().path+router.getState().name !== 'pages/Login') {
                            router.replaceUrl({ url: 'pages/Login' })
                        }
                    }
                    reject(false)
                }
            } else {
                promptAction.showToast({ message: "APP异常：" + JSON.stringify(err["message"]), duration: 3000 });
                console.info('errorssss:' + JSON.stringify(err));
                reject(false)
            }
            // 取消订阅HTTP响应头事件
            httpRequest.off('headersReceive');
            // 当该请求使用完毕时，调用destroy方法主动销毁。
            httpRequest.destroy();
        })
    })
}
