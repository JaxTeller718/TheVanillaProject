# BepInEx running script
# This script is used to run a Unity game server with BepInEx enabled.
# Usage: Configure the script below and simply run this script when you want to run your game modded.

# Server configuration file location
config_file="serverconfig.xml"
current_time=$(date "+%Y.%m.%d-%H.%M.%S")

# Name of the executable to run
executable_name="7DaysToDieServer.x86_64"

# ----- DO NOT EDIT FROM THIS LINE FORWARD  ------
# ----- (unless you know what you're doing) ------
a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)
export DOORSTOP_ENABLE=TRUE
export DOORSTOP_INVOKE_DLL_PATH="$BASEDIR/BepInEx/core/BepInEx.Preloader.dll"
export DOORSTOP_CORLIB_OVERRIDE_PATH="BepInEx/core"
if [ "$2" = "SteamLaunch" ]; then
    "$1" "$2" "$3" "$4" "$0" "$5"
    exit
fi

if [ ! -x "$1" -a ! -x "$executable_name" ]; then
    echo "Please open run.sh in a text editor and configure executable name."
    exit 1
fi

doorstop_libs="$BASEDIR/doorstop_libs"
arch=""
executable_path=""
lib_postfix=""

os_type=$(uname -s)
case $os_type in
    Linux*)
        executable_path="$BASEDIR/${executable_name}"
        lib_postfix="so"
        ;;
    Darwin*)
        executable_name=$(basename "${executable_name}" .app)
        real_executable_name=$(defaults read "$BASEDIR/${executable_name}.app/Contents/Info" CFBundleExecutable)
        executable_path="$BASEDIR/${executable_name}.app/Contents/MacOS/${real_executable_name}"
        lib_postfix="dylib"
        ;;
    *)
        echo "Cannot identify OS (got $(uname -s))!"
        echo "Please create an issue at https://github.com/BepInEx/BepInEx/issues."
        exit 1
        ;;
esac
if [ -n "$1" ]; then
    case $os_type in
        Linux*)
            executable_path="$1"
            ;;
        Darwin*)
            # Special case: allow to specify path to the executable within .app
            full_path_part=$(echo "$1" | grep "\.app/Contents/MacOS")
            if [ -z "$full_path_part" ]; then
                executable_name=$(basename "$1" .app)
                real_executable_name=$(defaults read "$1/Contents/Info" CFBundleExecutable)
                executable_path="$1/Contents/MacOS/${real_executable_name}"
            else
                executable_path="$1"
            fi
            ;;
    esac
fi

abs_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

_readlink() {
    ab_path="$(abs_path "$1")"
    link="$(readlink "${ab_path}")"
    case $link in
        /*);;
        *) link="$(dirname "$ab_path")/$link";;
    esac
    echo "$link"
}


resolve_executable_path () {
    e_path="$(abs_path "$1")"
    
    while [ -L "${e_path}" ]; do 
        e_path=$(_readlink "${e_path}");
    done
    echo "${e_path}"
}

executable_path=$(resolve_executable_path "${executable_path}")
echo "${executable_path}"
executable_type=$(LD_PRELOAD="" file -b "${executable_path}");

case $executable_type in
    *PE32*)
        echo "The executable is a Windows executable file. You must use Wine/Proton and BepInEx for Windows with this executable."
        echo "Uninstall BepInEx for *nix and install BepInEx for Windows instead."
        echo "More info: https://docs.bepinex.dev/articles/advanced/steam_interop.html#protonwine"
        exit 1
        ;;
    *64-bit*)
        arch="x64"
        ;;
    *32-bit*|*i386*)
        arch="x86"
        ;;
    *)
        echo "Cannot identify executable type (got ${executable_type})!"
        echo "Please create an issue at https://github.com/BepInEx/BepInEx/issues."
        exit 1
        ;;
esac

doorstop_libname=libdoorstop_${arch}.${lib_postfix}
export LD_LIBRARY_PATH="${doorstop_libs}":${LD_LIBRARY_PATH}
export LD_PRELOAD=$doorstop_libname:$LD_PRELOAD
export DYLD_LIBRARY_PATH="${doorstop_libs}"
export DYLD_INSERT_LIBRARIES="${doorstop_libs}/$doorstop_libname"

"${executable_path}" -configfile=$config_file -logfile output_log__"$current_time".txt -quit -batchmode -nographics -dedicated
