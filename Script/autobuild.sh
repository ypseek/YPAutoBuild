#!/bin/bash

cd $(dirname "$0")/..

#启动工程名字
workspace="xxxxx.xcworkspace"
#打包的scheme
scheme="xxxxx"
#infoPlist文件路径
infoPlist="xxxxx/Info.plist"

if [ "$1" = "Debug" ] || [ "$1" = "DEBUG" ] || [ "$1" = "debug" ] || [ "$1" = "D" ] || [ "$1" = "d" ]; then
configuration="Debug"
elif [ "$1" = "Release" ] || [ "$1" = "RELEASE" ] || [ "$1" = "release" ] || [ "$1" = "R" ] || [ "$1" = "r" ]; then
configuration="Release"
else
configuration="Debug"
fi
echo "当前编译的是${configuration}包"

shortVersion=`grep -A1 CFBundleShortVersionString ${infoPlist} | grep -o '\d\+\.\d\+\.\d\+'`
bundleVersion=`grep -A1 CFBundleVersion ${infoPlist} | grep -o '\d\+'`
filename="wxsh-ios-${shortVersion}.${bundleVersion}-$(echo ${configuration} | tr 'A-Z' 'a-z')-$(date +%y%m%d%H%M)"

xcodebuild clean -workspace ${workspace} -scheme ${scheme} -configuration ${configuration} -alltargets
xcodebuild archive -workspace ${workspace} -scheme ${scheme} -configuration ${configuration} -archivePath temp.xcarchive
if [ $? != 0 ]; then
	echo 'Error: 编译失败，请询问开发同学！'
	exit 2
fi
xcodebuild -exportArchive -archivePath temp.xcarchive -exportPath ~/Desktop/ipa/${scheme}-${configuration}.ipa -exportOptionsPlist Script/ExportOptions.plist

#清理
rm -rf temp.xcarchive

if [ "$configuration" = "Debug" ]; then
cd ~/Desktop/ipa/${scheme}-${configuration}.ipa
echo "-------开始蒲公英上传--------"
#蒲公英aipKey
MY_PGY_API_K="xxxxx"
#蒲公英uKey
MY_PGY_UK="xxxxx"
#上传到蒲公英
curl -F "file=@${scheme}.ipa" -F "uKey=${MY_PGY_UK}" -F "_api_key=${MY_PGY_API_K}" https://qiniu-storage.pgyer.com/apiv1/app/upload
else
echo "当前编译的是${configuration}包"
fi
