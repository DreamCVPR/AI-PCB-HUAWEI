import http from '@ohos.net.http'
import fs from '@ohos.file.fs';

// 后端API地址
const baseUrl = 'http://192.168.0.114:6666/api'

// 通用请求实现
export async function requests(options) {

    let {url, method, data, isFile} = options
    if (url.substring(0, 4) !== "http") {
        url = baseUrl + url
    }

    let httpRequest = http.createHttp();
    let header = {
        'Content-Type': 'application/json;charset=UTF-8'
    }
    if (isFile) {
        header['Content-Type'] = 'multipart/form-data'
        // const formData = http.FormData.create();
        // formData.append('files', {});
        // data = formData;
        // const formData = new FormData();
        // for (let key in data) {
        //     formData.append(key, data[key]);
        // }
        // data = formData;
    }

    const token = AppStorage.get('token')
    if (token) header['Access-Token'] = token
    console.log('base64', data.files);
    return new Promise((resolve, reject) => {

        httpRequest.request(
            url,
            {
                method: method.toUpperCase(), // 可选，默认为http.RequestMethod.GET
                header: header,
                // extraData: data,
                multiFormDataList: [ // 可选，仅当Header中，'content-Type'为'multipart/form-data'时生效，自API 11开始支持该属性
                    {
                        name: "task_name", // 数据名，自API 11开始支持该属性
                        contentType: 'text/plain', // 数据类型，自API 11开始支持该属性
                        data: 'syz123'
                    }, {
                        name: "task_desc", // 数据名，自API 11开始支持该属性
                        contentType: 'text/plain', // 数据类型，自API 11开始支持该属性
                        data: 'syz333'
                        },
                    {
                        name: "files",
                        contentType: 'text/plain',
                        data: data.files
                        // internal://cache/test.jpg
                        // filePath: 'internal://cache/test.jpg',
                        // remoteFileName: 'NewFile.txt'
                    }
                    ],
                connectTimeout: 60000, // 可选，默认为60000ms
                readTimeout: 60000, // 可选，默认为60000ms
                // usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
            }, (err, data) => {
            if (!err) {
                resolve(JSON.parse(data.result))
            } else {
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


export async function requests2(options) {
    let {url, method, data, isFile} = options
    if (url.substring(0, 4) !== "http") {
        url = baseUrl + url
    }

    let httpRequest = http.createHttp();
    let header = {
        'Content-Type': 'application/json;charset=UTF-8'
    }
    if (isFile) {
        header['Content-Type'] = 'multipart/form-data'
        // const formData = http.FormData.create();
        // formData.append('files', {});
        // data = formData;
        // const formData = new FormData();
        // for (let key in data) {
        //     formData.append(key, data[key]);
        // }
        // data = formData;
    }

    const token = AppStorage.get('token')
    if (token) header['Access-Token'] = token
    console.log('base64', data.files);
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

