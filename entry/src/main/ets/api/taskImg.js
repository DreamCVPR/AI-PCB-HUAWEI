import { requests } from '../utils/request'


export function getTaskImg (parameter) {
    return requests({
        url: '/taskImg/query',
        method: 'post',
        data: parameter
    })
}