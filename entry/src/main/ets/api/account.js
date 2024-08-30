import { requests } from '../utils/request'


export function login (parameter) {
  return requests({
    url: '/account/login',
    method: 'post',
    data: parameter,
  })
}