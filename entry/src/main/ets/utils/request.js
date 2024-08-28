import store from '../utils/store.js'
import http from '@ohos.net.http'

const baseUrl = 'http://192.168.0.114:6666/api'

async function request(options) {
    let {url, method, data} = options
    if (url.substring(0, 4) !== "http") {
        url = baseUrl + url
    }

    let httpRequest = http.createHttp();

    let header = {
        'Content-Type': 'application/json;charset=UTF-8'
    }
    const token = await store.get('token')
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
                resolve(JSON.parse(data.result))
            } else {
                console.info('error:' + JSON.stringify(err));
                reject(false)
            }
            // 取消订阅HTTP响应头事件
            httpRequest.off('headersReceive');
            // 当该请求使用完毕时，调用destroy方法主动销毁。
            httpRequest.destroy();
        })
    })
}

export default request
