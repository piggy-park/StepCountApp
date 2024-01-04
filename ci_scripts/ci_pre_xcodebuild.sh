#!/bin/sh

#  ci_pre_xcodebuild.sh
#  StepCountApp
#
#  Created by gx_piggy on 1/3/24.
#  
echo "pre xcode build script phase"

# 새로운 버전 번호 설정
NEW_VERSION=5.0.0

DIR=$(pwd)
echo "current path"
echo $DIR
echo "current tag $CI_TAG"

cd ..

xcrun agvtool new-marketing-version $NEW_VERSION

echo "Updated MARKETING_VERSION to $NEW_VERSION"
