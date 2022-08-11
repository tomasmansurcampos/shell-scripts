python3_()
{
    VERSION_=3.10.2
    apt install -y build-essential gcc g++ zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
    wget --https-only https://www.python.org/ftp/python/$VERSION_/Python-$VERSION_.tar.xz
    tar -xf Python-$VERSION_.tar.xz
    cd Python-$VERSION_.tar.xz
    mkdir --parents debug
    ../configure --enable-optimizations
    make -j $(expr $(nproc) - 1)
    make altinstall
}
python3_
