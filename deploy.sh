#!/bin/bash
echo -n "Checking Go version..."
GO_VERSION=`go version|grep 1.7.3 -c`
if [ "$GO_VERSION" != "1" ]; then
    echo "[FAIL]: Go1.7.3 is not installed. Please check gvm setting."
    exit 1
fi
echo [GO1.7.3]

echo -n "Checking eywa repo..."
EYWA_SRC="$GOPATH/src/github.com/eywa"
if [ ! -d "${EYWA_SRC}" ]; then
    echo "[FAIL]: eywa repo does not exist. Please clone the repo."
    exit 1
fi
echo [SUCCESS]

echo -n "Update eywa repo..."
pushd ${EYWA_SRC} > /dev/null 2>&1
git pull origin > /dev/null 2>&1
if [ "$?" != 0 ]; then
    echo "[FAIL]: eywa repo fails to update. Please check git setting."
    exit 1
fi
popd > /dev/null 2>&1
echo "[SUCCESS]"

echo -n "Installing eywa..."
go install github.com/eywa
if [ "$?" != 0 ]; then
    echo "[FAIL]: installation fails. Please check git setting."
    exit 1
fi
echo "[SUCCESS]"

echo -n "Configure eywa environment..."
export EYWA_HOME="$GOPATH/bin/"
if [ ! -d "${EYWA_HOME}/configs" ]; then
    mkdir ${EYWA_HOME}/configs
fi
cp ${EYWA_SRC}/configs/eywa_development.yml ${EYWA_HOME}/configs/
if [ ! -d "${EYWA_HOME}/db" ]; then
    mkdir ${EYWA_HOME}/db
fi
echo "[SUCCESS]"

echo -n "Move admin page..."
if [ -f dist.tar ]; then
    tar -xvf dist.tar > /dev/null 2>&1
    rm -rf ${EYWA_HOME}/assets
    mv dist ${EYWA_HOME}/assets
    echo "[SUCCESS]"
else
    echo "[NOTHING]"
fi

echo -n "Database migrate..."
eywa migrate > /dev/null 2>&1
if [ "$?" != 0 ]; then
    echo "[FAIL]: fail to migrate database. Please check configs."
    exit 1
fi
echo "[SUCCESS]"

echo -n "Elasticsearch setup..."
eywa setup_es > /dev/null 2>&1
if [ "$?" != 0 ]; then
    echo "[FAIL]: fail to set up ES. Please check ES and configs."
    exit 1
fi
echo "[SUCCESS]"
