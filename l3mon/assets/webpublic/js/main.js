function sendCommand(commandID, params = {}, cb = () => { }) {
    let queryString = $.param(params);
    let url = baseURL + '/' + commandID + '?' + queryString;
    $.post(url, function (data) {
        console.log(data);
        if (data.error) return cb(data.error, undefined)
        else return cb(false, data.message);
    });
}

function showNotification(backgroundColor, text) {
    Snackbar.show({ text, backgroundColor, pos: 'top-right', showAction: false });
}

function deleteDevice(deviceID) {
    if (!confirm('Delete device ' + deviceID + '? This cannot be undone.')) return;
    var url = '/manage/' + deviceID + '/delete';
    $.post(url, function (data) {
        if (data.error) {
            showNotification('#f03434', data.error);
        } else {
            showNotification('#2ecc71', data.message);
            setTimeout(function () { window.location = '/'; }, 1000);
        }
    });
}

function toggleWakeLock(element, deviceID) {
    $(element).addClass('loading');
    var url = '/manage/' + deviceID + '/0xWL';
    $.post(url, function (data) {
        $(element).removeClass('loading');
        if (data.error) {
            showNotification('#f03434', data.error);
        } else {
            showNotification('#2ecc71', data.message);
        }
    });
}

function updateButton(element, commandID, additionalParams = {}) {
    $(element).addClass('loading');
    sendCommand(commandID, additionalParams, (error, message) => {
        // ok, yes, i'm adding 'fake' delay, it just makes the front end nicer, okay!?
        if (error) {
            setTimeout(() => {
                showNotification('#f03434', error)
                $(element).removeClass('loading')
            }, 300)
        } else {
            setTimeout(() => {
                showNotification('#2ecc71', message);
                $(element).removeClass('loading');
                if (message === 'Requested') setTimeout(() => { window.location = window.location }, 200)
            }, 300)
        }
    });
}