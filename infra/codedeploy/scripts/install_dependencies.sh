#!/bin/sh
set -x
VERSION="1.10.2"
OS="linux"
ARCH="amd64"
GO_BUNDLE="go${VERSION}.${OS}-${ARCH}.tar.gz"

#which go
#if [ $? -ne 0 ] || [ ! -e /usr/local/go/bin/go ] || [ "`go version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'`" != "$VERSION" ]; then
#    echo "installing go version $VERSION"
#    wget https://dl.google.com/go/${GO_BUNDLE} -O /tmp/${GO_BUNDLE}
#    tar -C /usr/local -xzf /tmp/go$VERSION.$OS-$ARCH.tar.gz
#    rm -f /tmp/go$VERSION.$OS-$ARCH.tar.gz
#    export PATH=$PATH:/usr/local/go/bin
#    echo "export PATH=$PATH:/usr/local/go/bin" > /etc/profile.d/gopath.sh
#else
#    echo "go version $VERSION already installed"
#fi


# install ginkgo/gomega
which git
if [ $? -ne 0 ]; then
    echo "installing git"
    yum install -y git
else
    echo "git already installed"
fi
#go get -u github.com/onsi/ginkgo/ginkgo
#go get -u github.com/onsi/gomega/...
