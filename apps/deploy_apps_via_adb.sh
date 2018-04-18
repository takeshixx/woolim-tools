#!/bin/bash
script=${0##*/}

if [ $# -lt 2 ];then
    echo "Usage: ${script} <adb command> <archive file>" >&2
    echo "Example: ${script} \"Android/Sdk/platform-tools/adb -s emulator-5556\" woolimdicts.tar.gz" >&2
    exit 2
fi

ADB="$1"
ARCHIVE="$2"
TMPDIR=$(mktemp -dt adbdeploy.XXXXXX)
trap exit_script EXIT TERM

deploy_elecdict(){
    #ElecDict.apk / E-K-C Dictionary
    $ADB shell mkdir /storage/sdcard/프로그람자료
    $ADB push "${TMPDIR}/dicts/elecdict/Elecdict" /storage/sdcard/프로그람자료
    $ADB install "${TMPDIR}/dicts/elecdict/ElecDict.apk"
}

deploy_samhung(){
    #Samhung_2012_pre.apk / Samhung
    $ADB shell mount -o rw,remount /
    $ADB shell mkdir /data/flash
    $ADB shell ln -s /data/flash /flash
    $ADB push "${TMPDIR}/dicts/samhung/samhung" /flash
    $ADB install "${TMPDIR}/dicts/samhung/Samhung_2012_pre.apk"
}

deploy_okpyon(){
    #Okpyon.apk / Okpyon
    $ADB shell mkdir /storage/sdcard/프로그람자료
    $ADB push "${TMPDIR}/dicts/okpyon/okpyon" /storage/sdcard/프로그람자료
    $ADB install "${TMPDIR}/dicts/okpyon/Okpyon.apk"
}

check_adb(){
    output=$(eval "${ADB} root")
    if [ -z "$output" -o "$output" != "adbd is already running as root" ];then
        echo "Invalid adb command supplied"
        exit 1
    fi
}

exit_script(){
    echo "[*] Deleting temp directory..."
    rm -rf "$TMPDIR"
}

main(){
    if [ -z "$ADB" ];then
        echo "[e] adb not found."
        exit 1
    fi
    check_adb
    echo "[*] Unpacking archive..."                 
    tar xzf app_release_woolim_1.tar.gz -C $TMPDIR 2>/dev/null
    echo "[*] Deploying E-C-K Dictionary"
    deploy_elecdict
    echo "[*] Deploying Sam Hung"
    deploy_samhung
    echo "[*] Deploying Okpyon"
    deploy_okpyon
}

main
