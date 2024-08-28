import storage from '@system.storage'

function set(key, value) {
    return new Promise((resolve, reject) => {
        storage.set({
            key: key,
            value: value,
            success: function() {
                resolve(value);
            },
            fail: function(data, code) {
                reject('storage.set fail, code: ' + code + ', data: ' + data);
            }
        })
    });
}

function get(key) {
    return new Promise((resolve, reject) => {
        storage.get({
            key: key,
            success: function(data) {
                resolve(data);
            },
            fail: function(data, code) {
                reject('storage.set fail, code: ' + code + ', data: ' + data);
            }
        })
    });
}

function del(key) {
    return new Promise((resolve, reject) => {
        storage.delete({
            key: key,
            success: function() {
                resolve(key);
            },
            fail: function(error) {
                reject('storage.delete fail: ' + error);
            }
        });
    });
}

function clear() {
    return new Promise((resolve, reject) => {
        storage.clear({
            success: function() {
                resolve('success');
            },
            fail: function(error) {
                reject('storage.clear fail: ' + error);
            }
        });
    });
}

export default class store {
    static async get(key) {
        try {
            let data = await get(key)
            return data
        } catch (error) {
            console.error(error);
            return error
        }
    };
    static async set(key, value) {
        try {
            if (typeof value !== 'string') value = JSON.stringify(value)
            let data = await set(key, value)
            return data
        } catch (error) {
            console.error(error);
            return error
        }
    };
    static async delete(key) {
        try {
            let data = await del(key)
            return data
        } catch (error) {
            console.error(error);
            return error
        }
    };
    static async clear() {
        try {
            let data = await clear()
            return data
        } catch (error) {
            console.error(error);
            return error
        }
    };

    static async ww() {
        await console.log('222222')
    };
}

