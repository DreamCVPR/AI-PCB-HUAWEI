import { requests } from '../utils/request'

// 增加任务
export function addTask (parameter, message) {
    return requests({
        url: '/task/add',
        method: 'post',
        data: parameter,
        message: message
    })
}

// 开始检测
export function startDet (parameter, message) {
    return requests({
        url: '/task/detect',
        method: 'post',
        data: parameter,
        message: message
    })
}

// 获取任务
export function getTasks (parameter) {
    return requests({
        url: '/task/query',
        method: 'post',
        data: parameter
    })
}

// 删除任务
export function delTask(parameter, message) {
    return requests({
        url: '/task/remove',
        method: 'post',
        data: parameter,
        message: message
    })
}