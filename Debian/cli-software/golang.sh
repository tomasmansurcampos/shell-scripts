#!/bin/bash

install_()
{
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

are_updated_()
{
    INSTALLED_VERSION_=$(go version | cut -d " " -f 3)
    INSTALLED_VERSION_=${INSTALLED_VERSION_:2}
    if [ "$(printf '%s\n' "$VERSION_" "$INSTALLED_VERSION_" | sort -V | head -n1)" = "$VERSION_" ]; then 
        echo 1
    else
        echo 0
    fi
}

golang_bin_()
{
    VERSION_=$(curl -s https://go.dev/dl/ | grep toggleVisible | head -n 1 | grep -Po 'id="\K[^"]+')
    VERSION_=${VERSION_:2}

    if ! command -v /usr/local/go/bin/go &> /dev/null
    then
        echo -e "Installing go language..."
        install_
    else
        if ${are_updated_}
        then
            echo -e "\nLatest go version is installed!"
        else
            echo -e "Go language is not updated..."
            echo "Installing latest version"
            install_
        fi
    fi
}

apt install --no-install-recommends -y curl wget
golang_bin_
