#!/bin/bash

# สคริปต์สร้าง rootfs.tar.xz แบบสมบูรณ์ (Deep)
# สำหรับใช้กับ Docker FROM scratch

set -e

# ตัวแปรการตั้งค่า
ROOTFS_DIR="rootfs"
OUTPUT_FILE="rootfs.tar.xz"
ARCH="x86_64"  # หรือ aarch64, armv7l ตามต้องการ

echo "🚀 เริ่มสร้าง Deep RootFS..."

# 1. สร้างโครงสร้างไดเรกทอรี่พื้นฐาน
create_directory_structure() {
    echo "📁 สร้างโครงสร้างไดเรกทอรี่..."
    
    mkdir -p $ROOTFS_DIR/{bin,sbin,etc,dev,proc,sys,tmp,var,usr,lib,lib64,root,home,opt,mnt,media,run,srv}
    
    # โครงสร้างใน /usr
    mkdir -p $ROOTFS_DIR/usr/{bin,sbin,lib,lib64,local,share,include}
    mkdir -p $ROOTFS_DIR/usr/local/{bin,sbin,lib,share}
    
    # โครงสร้างใน /var
    mkdir -p $ROOTFS_DIR/var/{log,tmp,cache,lib,spool,run,lock,opt}
    
    # โครงสร้างใน /etc
    mkdir -p $ROOTFS_DIR/etc/{init.d,network,security,ssl,systemd}
    
    chmod 755 $ROOTFS_DIR/tmp
    chmod 755 $ROOTFS_DIR/var/tmp
    chmod 1777 $ROOTFS_DIR/tmp $ROOTFS_DIR/var/tmp
}

# 2. ติดตั้งระบบปฏิบัติการพื้นฐาน (Alpine Linux)
install_base_system() {
    echo "🏗️  ติดตั้งระบบปฏิบัติการพื้นฐาน..."
    
    # ดาวน์โหลดและติดตั้ง Alpine Linux minirootfs
    ALPINE_VERSION="3.19"
    ALPINE_ARCH="x86_64"
    
    if [ "$ARCH" = "aarch64" ]; then
        ALPINE_ARCH="aarch64"
    elif [ "$ARCH" = "armv7l" ]; then
        ALPINE_ARCH="armv7"
    fi
    
    ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/${ALPINE_ARCH}/alpine-minirootfs-${ALPINE_VERSION}.0-${ALPINE_ARCH}.tar.gz"
    
    echo "ดาวน์โหลด Alpine Linux..."
    wget -O alpine-minirootfs.tar.gz "$ALPINE_URL"
    
    echo "แตกไฟล์ Alpine Linux..."
    tar -xzf alpine-minirootfs.tar.gz -C $ROOTFS_DIR/
    
    rm alpine-minirootfs.tar.gz
}

# 3. ติดตั้ง Essential Tools และ Libraries
install_essential_tools() {
    echo "🔧 ติดตั้งเครื่องมือและ Libraries ที่จำเป็น..."
    
    # ใช้ chroot เพื่อติดตั้งแพ็คเกจใน Alpine
    mount --bind /proc $ROOTFS_DIR/proc
    mount --bind /sys $ROOTFS_DIR/sys
    mount --bind /dev $ROOTFS_DIR/dev
    
    # Copy resolv.conf สำหรับการเชื่อมต่ออินเทอร์เน็ต
    cp /etc/resolv.conf $ROOTFS_DIR/etc/
    
    # ติดตั้งแพ็คเกจพื้นฐาน
    chroot $ROOTFS_DIR /bin/sh -c "
        # อัปเดต package index
        apk update
        
        # ติดตั้งเครื่องมือพื้นฐาน
        apk add --no-cache \
            bash \
            busybox \
            coreutils \
            curl \
            wget \
            tar \
            gzip \
            xz \
            ca-certificates \
            openssl \
            shadow \
            util-linux \
            procps \
            findutils \
            grep \
            sed \
            gawk \
            vim \
            nano \
            less \
            tree \
            htop \
            net-tools \
            iproute2 \
            iptables \
            openssh-client \
            rsync \
            git \
            make \
            gcc \
            g++ \
            musl-dev \
            linux-headers \
            python3 \
            py3-pip \
            nodejs \
            npm
        
        # ทำความสะอาด cache
        apk cache clean
        rm -rf /var/cache/apk/*
    "
    
    # Unmount
    umount $ROOTFS_DIR/proc
    umount $ROOTFS_DIR/sys  
    umount $ROOTFS_DIR/dev
}

# 4. ติดตั้ง Development Tools
install_dev_tools() {
    echo "💻 ติดตั้ง Development Tools..."
    
    mount --bind /proc $ROOTFS_DIR/proc
    mount --bind /sys $ROOTFS_DIR/sys
    mount --bind /dev $ROOTFS_DIR/dev
    cp /etc/resolv.conf $ROOTFS_DIR/etc/
    
    chroot $ROOTFS_DIR /bin/sh -c "
        apk add --no-cache \
            build-base \
            cmake \
            autoconf \
            automake \
            libtool \
            pkgconfig \
            flex \
            bison \
            gdb \
            valgrind \
            strace \
            file \
            binutils \
            patch \
            diffutils
    "
    
    umount $ROOTFS_DIR/proc
    umount $ROOTFS_DIR/sys
    umount $ROOTFS_DIR/dev
}

# 5. ติดตั้ง Libraries ที่สำคัญ
install_important_libraries() {
    echo "📚 ติดตั้ง Libraries ที่สำคัญ..."
    
    mount --bind /proc $ROOTFS_DIR/proc
    mount --bind /sys $ROOTFS_DIR/sys
    mount --bind /dev $ROOTFS_DIR/dev
    cp /etc/resolv.conf $ROOTFS_DIR/etc/
    
    chroot $ROOTFS_DIR /bin/sh -c "
        apk add --no-cache \
            zlib-dev \
            openssl-dev \
            libffi-dev \
            sqlite-dev \
            readline-dev \
            ncurses-dev \
            gdbm-dev \
            xz-dev \
            tk-dev \
            libjpeg-turbo-dev \
            libpng-dev \
            freetype-dev \
            libxml2-dev \
            libxslt-dev \
            yaml-dev \
            pcre-dev \
            oniguruma-dev
    "
    
    umount $ROOTFS_DIR/proc
    umount $ROOTFS_DIR/sys
    umount $ROOTFS_DIR/dev
}

# 6. สร้างไฟล์การตั้งค่าระบบ
create_system_configs() {
    echo "⚙️  สร้างไฟล์การตั้งค่าระบบ..."
    
    # /etc/passwd
    cat > $ROOTFS_DIR/etc/passwd << 'EOF'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
EOF

    # /etc/group
    cat > $ROOTFS_DIR/etc/group << 'EOF'
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:
fax:x:21:
voice:x:22:
cdrom:x:24:
floppy:x:25:
tape:x:26:
sudo:x:27:
audio:x:29:
dip:x:30:
www-data:x:33:
backup:x:34:
operator:x:37:
list:x:38:
irc:x:39:
src:x:40:
gnats:x:41:
shadow:x:42:
utmp:x:43:
video:x:44:
sasl:x:45:
plugdev:x:46:
staff:x:50:
games:x:60:
users:x:100:
nogroup:x:65534:
EOF

    # /etc/shadow
    cat > $ROOTFS_DIR/etc/shadow << 'EOF'
root::19000:0:99999:7:::
daemon:*:19000:0:99999:7:::
bin:*:19000:0:99999:7:::
sys:*:19000:0:99999:7:::
sync:*:19000:0:99999:7:::
games:*:19000:0:99999:7:::
man:*:19000:0:99999:7:::
lp:*:19000:0:99999:7:::
mail:*:19000:0:99999:7:::
news:*:19000:0:99999:7:::
nobody:*:19000:0:99999:7:::
EOF
    chmod 640 $ROOTFS_DIR/etc/shadow

    # /etc/hostname
    echo "container" > $ROOTFS_DIR/etc/hostname
    
    # /etc/hosts
    cat > $ROOTFS_DIR/etc/hosts << 'EOF'
127.0.0.1   localhost
127.0.1.1   container
::1         localhost ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # /etc/profile
    cat > $ROOTFS_DIR/etc/profile << 'EOF'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PS1='\u@\h:\w\$ '
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

if [ -d /etc/profile.d ]; then
    for i in /etc/profile.d/*.sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
    unset i
fi
EOF

    # สร้าง /etc/profile.d
    mkdir -p $ROOTFS_DIR/etc/profile.d
    
    # Bash completion
    cat > $ROOTFS_DIR/etc/profile.d/bash_completion.sh << 'EOF'
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
EOF

}

# 7. สร้างไฟล์เริ่มต้น
create_init_files() {
    echo "🎯 สร้างไฟล์เริ่มต้น..."
    
    # .bashrc สำหรับ root
    cat > $ROOTFS_DIR/root/.bashrc << 'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export LS_OPTIONS='--color=auto'
eval "$(dircolors -b)" 2>/dev/null || true
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias la='ls -la'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# enable programmable completion features
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000
EOF

    # .profile สำหรับ root  
    cat > $ROOTFS_DIR/root/.profile << 'EOF'
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
EOF

    # สร้าง entrypoint script
    cat > $ROOTFS_DIR/entrypoint.sh << 'EOF'
#!/bin/bash

# Container entrypoint script
set -e

# Initialize environment
if [ ! -f /.initialized ]; then
    echo "Initializing container..."
    
    # Create necessary directories
    mkdir -p /var/run /var/lock /var/log
    
    # Set permissions
    chmod 755 /tmp /var/tmp
    chmod 1777 /tmp /var/tmp
    
    # Mark as initialized
    touch /.initialized
    
    echo "Container initialized successfully!"
fi

# Execute the command
exec "$@"
EOF

    chmod +x $ROOTFS_DIR/entrypoint.sh
}

# 8. ทำความสะอาดและเตรียมการ
cleanup_and_prepare() {
    echo "🧹 ทำความสะอาดและเตรียมการ..."
    
    # ลบไฟล์ที่ไม่จำเป็น
    rm -rf $ROOTFS_DIR/tmp/*
    rm -rf $ROOTFS_DIR/var/tmp/*
    rm -rf $ROOTFS_DIR/var/cache/apk/*
    rm -rf $ROOTFS_DIR/var/log/*
    rm -f $ROOTFS_DIR/etc/resolv.conf
    
    # ลบ history files
    rm -f $ROOTFS_DIR/root/.ash_history
    rm -f $ROOTFS_DIR/root/.bash_history
    
    # สร้าง device nodes พื้นฐาน
    mknod -m 666 $ROOTFS_DIR/dev/null c 1 3 2>/dev/null || true
    mknod -m 666 $ROOTFS_DIR/dev/zero c 1 5 2>/dev/null || true
    mknod -m 666 $ROOTFS_DIR/dev/random c 1 8 2>/dev/null || true
    mknod -m 666 $ROOTFS_DIR/dev/urandom c 1 9 2>/dev/null || true
    mknod -m 620 $ROOTFS_DIR/dev/console c 5 1 2>/dev/null || true
    mknod -m 666 $ROOTFS_DIR/dev/tty c 5 0 2>/dev/null || true
    mknod -m 666 $ROOTFS_DIR/dev/ptmx c 5 2 2>/dev/null || true
    
    # สร้าง symlinks ที่สำคัญ
    ln -sf /proc/self/fd $ROOTFS_DIR/dev/fd 2>/dev/null || true
    ln -sf /proc/self/fd/0 $ROOTFS_DIR/dev/stdin 2>/dev/null || true
    ln -sf /proc/self/fd/1 $ROOTFS_DIR/dev/stdout 2>/dev/null || true
    ln -sf /proc/self/fd/2 $ROOTFS_DIR/dev/stderr 2>/dev/null || true
    
    # ตั้งค่า permissions ที่ถูกต้อง
    chmod 755 $ROOTFS_DIR/bin/* 2>/dev/null || true
    chmod 755 $ROOTFS_DIR/sbin/* 2>/dev/null || true
    chmod 755 $ROOTFS_DIR/usr/bin/* 2>/dev/null || true
    chmod 755 $ROOTFS_DIR/usr/sbin/* 2>/dev/null || true
    
    echo "✅ เตรียมการเสร็จสิ้น"
}

# 9. สร้าง tar.xz archive
create_tarxz() {
    echo "📦 สร้าง rootfs.tar.xz..."
    
    # สร้าง tar.xz ด้วยการบีบอัดสูงสุด
    cd $ROOTFS_DIR
    tar -cJf ../$OUTPUT_FILE \
        --numeric-owner \
        --preserve-permissions \
        --one-file-system \
        --exclude='./dev/*' \
        --exclude='./proc/*' \
        --exclude='./sys/*' \
        --exclude='./tmp/*' \
        --exclude='./var/tmp/*' \
        --exclude='./run/*' \
        .
    cd ..
    
    # แสดงข้อมูลไฟล์
    ls -lh $OUTPUT_FILE
    
    echo "✅ สร้าง $OUTPUT_FILE เสร็จสิ้น!"
}

# 10. สร้าง Dockerfile ตัวอย่าง
create_sample_dockerfile() {
    echo "🐳 สร้าง Dockerfile ตัวอย่าง..."
    
    cat > Dockerfile << EOF
# Dockerfile สำหรับ Deep RootFS
FROM scratch

# เพิ่ม rootfs
ADD rootfs.tar.xz /

# ตั้งค่าตัวแปรสภาพแวดล้อม
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV TERM="xterm"

# ตั้งค่า working directory
WORKDIR /root

# ใช้ entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# คำสั่งเริ่มต้น
CMD ["bash"]
EOF

    echo "✅ สร้าง Dockerfile เสร็จสิ้น!"
}



# 11. สร้าง build script readme
create_build_script() {
    echo "🔨 สร้าง build script..."
    
    cat > build.readme << 'EOF'


# Build image
docker build -t deep-rootfs:latest .

# Usage examples:

docker run -it deep-rootfs:latest
docker run -it deep-rootfs:latest python3
docker run -it deep-rootfs:latest node --version

EOF
    echo "✅ สร้าง build.readme เสร็จสิ้น!"
}

# 12. Main execution
main() {
    echo "🎯 เริ่มสร้าง Deep RootFS สำหรับ Docker FROM scratch"
    echo "=================================================="
    
    # ตรวจสอบสิทธิ์ root
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Error: ต้องรันด้วยสิทธิ์ root"
        echo "   sudo $0"
        exit 1
    fi
    
    
    # เรียกใช้ฟังก์ชันทั้งหมด
    create_directory_structure
    install_base_system
    install_essential_tools
    install_dev_tools
    install_important_libraries
    create_system_configs
    create_init_files
    cleanup_and_prepare
    create_tarxz
    create_sample_dockerfile
    create_build_script
    
    echo ""
    echo "🎉 สร้าง Deep RootFS เสร็จสิ้นแล้ว!"
    echo "=================================================="
    echo "ไฟล์ที่สร้างขึ้น:"
    echo "  - $OUTPUT_FILE ($(du -h $OUTPUT_FILE | cut -f1))"
    echo "  - Dockerfile"
    echo "  - docker-compose.yml"
    echo "  - build.sh"
    echo ""
    echo "วิธีใช้งาน:"
    echo "  อ่านไฟล์ build.readme              # สร้าง Docker image"
    echo ""
    echo "คุณสมบัติที่รวมอยู่:"
    echo "  ✅ Alpine Linux base system"
    echo "  ✅ Essential tools (bash, curl, wget, git, etc.)"
    echo "  ✅ Development tools (gcc, make, cmake, etc.)"
    echo "  ✅ Programming languages (Python3, Node.js)"
    echo "  ✅ Network tools (net-tools, iproute2, etc.)"
    echo "  ✅ System libraries และ development headers"
    echo "  ✅ Proper system configuration files"
    echo "  ✅ Security และ user management"
    echo ""
}

# รันฟังก์ชัน main
main "$@"