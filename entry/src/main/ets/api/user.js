import { requests } from '../utils/request'


export function getUserInfo (parameter) {
  return requests({
    url: '/user/getUserInfo ',
    method: 'post',
    data: parameter,
  })
}

export function updateUser (parameter ) {
  return requests({
    url: '/user/updateUser',
    method: 'post',
    data: parameter
  })
}

export function changeImg (parameter) {
  return requests({
    url: '/user/changeImage',
    method: 'post',
    data: parameter,
  })
}
export function resetPwd (parameter) {
  return requests({
    url: '/user/resetPwd',
    method: 'post',
    data: parameter,
  })
}