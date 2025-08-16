# Deep RootFS Builder 🚀

> สร้าง Complete RootFS สำหรับ Docker `FROM scratch` อย่างมืออาชีพ

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Alpine Linux](https://img.shields.io/badge/Base-Alpine%20Linux-blue.svg)](https://alpinelinux.org/)

## 📖 คำอธิบาย
Deep RootFS Builder เป็นสคริปต์ Bash ที่ได้รับแรงบันดาลใจจาก Linux From Scratch (LFS) - การสร้างระบบ Linux ตั้งแต่เริ่มต้น แต่ได้ปรับมาให้เข้ากับยุค container และ Docker เพื่อให้สามารถเข้าใจและสร้าง minimal Linux system ได้ง่ายขึ้น
โปรเจ็กต์นี้จึงเกิดขึ้นมาเป็น Lab สำหรับการเรียนรู้และทดลอง โดยช่วยสร้าง rootfs.tar.xz แบบสมบูรณ์สำหรับใช้กับ Docker FROM scratch มีฐานจาก Alpine Linux พร้อมเครื่องมือ development และ libraries ที่จำเป็นครบครุ่น
## 🎓 จุดประสงค์ของ Lab

เข้าใจโครงสร้างพื้นฐานของ Linux filesystem
เรียนรู้การสร้าง minimal Linux system
ทดลองการทำ Docker image ตั้งแต่เริ่มต้น (FROM scratch)
พัฒนาทักษะ system administration และ container technology
## 🎯 สิ่งที่ได้จากการใช้งาน

### เครื่องมือพื้นฐาน
- **Shell**: Bash, BusyBox
- **File Tools**: tar, gzip, xz, find, grep, sed, awk
- **Network**: curl, wget, openssh-client, net-tools
- **Editor**: vim, nano, less
- **System**: htop, tree, rsync

### Development Tools
- **Compilers**: GCC, G++, Make, CMake
- **Build Tools**: autoconf, automake, pkg-config
- **Debug Tools**: GDB, Valgrind, strace
- **Languages**: Python 3, Node.js, npm

### System Libraries
- **SSL/TLS**: OpenSSL
- **Compression**: zlib, xz, gzip
- **Image**: libjpeg, libpng, freetype
- **Database**: SQLite
- **XML/YAML**: libxml2, libxslt, yaml

## 🚀 การติดตั้งและใช้งาน

### ข้อกำหนดระบบ

- **OS**: Linux (Ubuntu, Debian, CentOS, etc.)
- **สิทธิ์**: Root access (sudo)
- **พื้นที่**: อย่างน้อย 2GB ว่าง
- **เครื่องมือ**: wget, tar, chroot

### วิธีการใช้งาน

1. **โคลนโปรเจ็กต์**
   ```bash
   git clone https://github.com/yourusername/deep-rootfs-builder.git
   cd deep-rootfs-builder
   ```

2. **รันสคริปต์ (ต้องใช้ sudo)**
   ```bash
   chmod +x ./build-deep-rootfs.sh
   sudo ./build-deep-rootfs.sh
   ```

3. **รอการประมวลผล** (ประมาณ 10-15 นาที)
   ```
   🚀 เริ่มสร้าง Deep RootFS...
   📁 สร้างโครงสร้างไดเรกทอรี่...
   🏗️ ติดตั้งระบบปฏิบัติการพื้นฐาน...
   🔧 ติดตั้งเครื่องมือและ Libraries...
   ...
   🎉 สร้าง Deep RootFS เสร็จสิ้นแล้ว!
   ```

4. **ได้ไฟล์ที่สร้างขึ้น**
   - `rootfs.tar.xz` - RootFS archive
   - `Dockerfile` - ตัวอย่าง Dockerfile
   - `build.readme` - คำแนะนำการ build

## 🐳 การใช้งานกับ Docker

### Build Docker Image

```bash
# Build image
docker build -t deep-rootfs:latest .

# หรือใช้ tag เฉพาะ
docker build -t myapp:v1.0 .
```

### ตัวอย่างการใช้งาน

```bash
# เริ่ม container แบบ interactive
docker run -it deep-rootfs:latest

# รัน Python
docker run -it deep-rootfs:latest python3

# รัน Node.js
docker run -it deep-rootfs:latest node --version

# Mount volume และรันคำสั่ง
docker run -v $(pwd):/workspace deep-rootfs:latest gcc /workspace/hello.c -o /workspace/hello
```

### Custom Dockerfile

```dockerfile
FROM scratch

# เพิ่ม rootfs
ADD rootfs.tar.xz /

# ตั้งค่า environment
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV LANG="C.UTF-8"

# Copy application
COPY myapp /usr/local/bin/

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["myapp"]
```

## ⚙️ การปรับแต่ง

### เปลี่ยน Architecture

แก้ไขในสคริปต์:
```bash
ARCH="aarch64"  # สำหรับ ARM64
# หรือ
ARCH="armv7l"   # สำหรับ ARM32
```

### เพิ่มแพ็กเกจเพิ่มเติม

ในฟังก์ชัน `install_essential_tools()`:
```bash
apk add --no-cache \
    your-package-here \
    another-package
```

### ปรับแต่งการตั้งค่า

แก้ไขในฟังก์ชัน `create_system_configs()` เพื่อปรับแต่ง:
- User accounts (`/etc/passwd`)
- Environment variables (`/etc/profile`)
- System settings



## 🔍 รายละเอียดเทคนิค

### ขั้นตอนการทำงาน

1. **Directory Structure**: สร้างโครงสร้างไดเรกทอรี่มาตรฐาน Linux
2. **Base System**: ติดตั้ง Alpine Linux minirootfs
3. **Essential Tools**: เพิ่มเครื่องมือพื้นฐานที่จำเป็น
4. **Development**: ติดตั้ง compiler และ dev tools
5. **Libraries**: เพิ่ม development libraries
6. **Configuration**: สร้างไฟล์ config ระบบ
7. **Initialization**: สร้าง entrypoint scripts
8. **Cleanup**: ทำความสะอาดและเตรียมการ
9. **Archive**: สร้าง tar.xz ที่บีบอัดแล้ว

### ขนาดไฟล์โดยประมาณ

- **Uncompressed**: ~500MB
- **Compressed (tar.xz)**: ~150-200MB
- **Docker Image**: ~180-220MB

### Security Features

- ✅ User และ group management
- ✅ Proper file permissions
- ✅ Shadow password system
- ✅ CA certificates
- ✅ SSH client configuration




## 🙏 Acknowledgments

- [Alpine Linux](https://alpinelinux.org/) สำหรับ base system
- [Linux From Scratch](https://linuxfromscratch.org/) สำหรับแนวคิด
- [Docker](https://docker.com/) สำหรับ containerization platform


⭐ ถ้าโปรเจ็กต์นี้มีประโยชน์ กรุณาให้ Star ด้วยนะครับ!