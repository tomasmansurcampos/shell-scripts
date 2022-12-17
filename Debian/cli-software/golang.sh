#!/bin/bash
golang_bin_()
{
    VERSION_=$(curl -s https://go.dev/dl/ | grep toggleVisible | head -n 1 | grep -Po 'id="\K[^"]+')
    VERSION_=${VERSION_:2}
    URL_=https://go.dev/dl/go$VERSION_.linux-$(dpkg --print-architecture).tar.gz
    if wget --spider $URL_ 2>/dev/null; then
        wget --https-only $URL_
        rm -rf /usr/local/go && tar -C /usr/local -xzf go$VERSION_.linux-$(dpkg --print-architecture).tar.gz
        cat << EOF > /etc/profile.d/user/go.sh
#!/bin/bash
export PATH=$PATH:/usr/local/go/bin
EOF
        rm -rf go$VERSION_.linux-$(dpkg --print-architecture).tar.gz
        source /root/.bashrc
    fi
}
golang_bin_
