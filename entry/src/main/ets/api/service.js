import { requests } from '../utils/request'


export function detect (parameter) {
    return requests({
        url: '/task/detect',
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

export function getTasks (parameter) {
    return requests({
        url: '/task/query',
        method: 'post',
        data: parameter
    })
}