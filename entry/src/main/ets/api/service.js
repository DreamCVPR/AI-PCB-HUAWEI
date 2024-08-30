import { requests } from '../utils/request'


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
    })
}

export function startDet (parameter) {
    return requests({
        url: '/task/detect',
        method: 'post',
        data: parameter,
    })
}