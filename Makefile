

shell:
	time python3 build_linux.py --podman \
		-s /home/amitkr/oss/linux/teeny-linux/linux \
		-o /home/amitkr/oss/linux/teeny-linux/KBUILD-OUT \
		-c clang-21 \
		-a x86_64 \
		--shell

build:
	time python3 build_linux.py --podman \
		-s /home/amitkr/oss/linux/teeny-linux/linux \
		-o /home/amitkr/oss/linux/teeny-linux/KBUILD-OUT \
		-c clang-21 \
		-a x86_64 \
		-k .config-akdebug

image-clang-18:
	time python3 manage_images.py -p -b clang-18

image-clang-21:
	time python3 manage_images.py -p -b clang-21
