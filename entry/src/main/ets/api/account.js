import request from '../utils/request'


export function login (parameter) {
  return request({
    url: '/account/getUserInfo',
    method: 'post',
    data: parameter
  })
}

export function getToken (parameter) {
  return request({
    url: 'https://iam.cn-southwest-2.myhuaweicloud.com/v3/auth/tokens',
    method: 'post',
    data: parameter
  })
}
