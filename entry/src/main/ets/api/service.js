import { requests, requests2 } from '../utils/request'


export function predict (parameter) {
    return requests({
        url: '/service/predict',
        method: 'post',
        data: parameter
    })
}

export function addTask (parameter) {
    return requests({
        url: '/task/add',
        method: 'post',
        data: parameter,
        isFile: true
    })
}

export function startDet (parameter) {
    return requests2({
        url: '/task/detect',
        method: 'post',
        data: parameter,
    })
}