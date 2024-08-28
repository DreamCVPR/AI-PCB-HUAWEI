import request from '../utils/request'


export function predict (parameter) {
    return request({
        url: '/service/predict',
        method: 'post',
        data: parameter
    })
}
