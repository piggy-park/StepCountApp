#!/bin/sh

#  ci_pre_xcodebuild.sh
#  StepCountApp
#
#  Created by gx_piggy on 1/3/24.
#  
echo "pre xcode build script phase"

# 새로운 버전 번호 설정
NEW_VERSION="5.0.0"

# Info.plist 파일 경로 설정
PLIST_FILE="StepCountApp/Info.plist"

# MARKETING_VERSION 업데이트
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" "$PLIST_FILE"

echo "Updated MARKETING_VERSION to $NEW_VERSION"
