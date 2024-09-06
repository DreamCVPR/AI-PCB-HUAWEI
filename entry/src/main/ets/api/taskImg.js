import { requests } from '../utils/request'


export function getTaskImg (parameter) {
    return requests({
        url: '/taskImg/query',
        method: 'post',
        data: parameter
    })
}

export function removeImg (parameter) {
    return requests({
        url: '/taskImg/remove',
        method: 'post',
        data: parameter
    })
}

export function addImg (parameter) {
    return requests({
        url: '/taskImg/add',
        method: 'post',
        data: parameter
    })
}

export function changeTask (parameter) {
    return requests({
        url: '/taskImg/changeTask',
        method: 'post',
        data: parameter
    })
}

export function detect (parameter) {
    return requests({
        url: '/taskImg/detect',
        method: 'post',
        data: parameter
    })
}