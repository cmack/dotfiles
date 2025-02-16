;; This is an operating system configuration generated
;; by the graphical installer.

(define-module (cmack systems multivec)
  #:use-module (gnu)
  #:use-module (srfi srfi-1)
  #:use-module (gnu system nss)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd))

(use-service-modules guix
                     cups
                     desktop
                     networking
                     sound
                     ssh
                     xorg
                     avahi
                     docker
                     virtualization
                     admin)

(use-package-modules version-control emacs vim linux wm radio)

(define %nonguix-substitutes-service
  (simple-service 'add-nonguix-substitutes guix-service-type
                  (guix-extension (substitute-urls (append (list
                                                            "https://substitutes.nonguix.org")
                                                    %default-substitute-urls))
                                  (authorized-keys (append (list (plain-file
                                                                  "nonguix.pub"
                                                                  "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                                    %default-authorized-guix-keys)))))
(operating-system
  (kernel linux)
  (kernel-arguments (append %default-kernel-arguments
                            (list "modprobe.blacklist=dvb_usb_rtl28xxu" ; Needed for rtl-sdr
                                  ;; "ideapad_laptop.allow_v4_dytc=1"
                                  ;; "acpi.backlight=video"
                             )))
  (initrd microcode-initrd)
  (firmware (list linux-firmware realtek-firmware amdgpu-firmware))
  (locale "en_US.utf8")
  (timezone "America/Chicago")
  (keyboard-layout (keyboard-layout "us"
                                    #:options '("ctrl:swapcaps")
                                    #:model "thinkpad"))
  (host-name "multivec")

  (users (cons* (user-account
                  (name "charlie")
                  (comment "Charlie")
                  (group "users")
                  (home-directory "/home/charlie")
                  (supplementary-groups '("wheel" "netdev"
                                          "audio"
                                          "video"
                                          "input"
                                          "kvm"
                                          "lp"
                                          "tty"
                                          "docker"
                                          "dialout"  ; rtl-sdr use
                                          ))) %base-user-accounts))

  (packages (cons* git
                   emacs
                   vim
                   light
                   sway
                   swayidle
                   swaylock
                   rtl-sdr
                   %base-packages))

  (services
   (append (modify-services %desktop-services
             (delete gdm-service-type)
             (delete screen-locker-service-type))
           (list %nonguix-substitutes-service
                 (service openssh-service-type)
                 ;; (udev-rules-service 'light backlight-service #:groups '("video"))
                 (service screen-locker-service-type
                          (screen-locker-configuration (name "swaylock")
                                                       (program (file-append
                                                                 swaylock
                                                                 "/bin/swaylock"))
                                                       (allow-empty-password?
                                                                              #f)
                                                       (using-pam? #t)
                                                       (using-setuid? #f)))
                 (service file-database-service-type)
                 (service containerd-service-type)
                 (service docker-service-type)
                 (service sane-service-type)
                 (service cups-service-type
                          (cups-configuration (web-interface? #t)))
                 ;; (screen-locker-service kbd "vlock")
                 (udev-rules-service 'backlight light)
                 (udev-rules-service 'rtl-sdr rtl-sdr))))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))
                (keyboard-layout keyboard-layout)))

  (mapped-devices (list (mapped-device
                          (source (uuid "43baf573-50e8-46e5-9595-666f640191d5"))
                          (target "cryptroot")
                          (type luks-device-mapping))))

  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "AB78-C45C"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device "/dev/mapper/cryptroot")
                         (type "ext4")
                         (dependencies mapped-devices)) %base-file-systems))

  (swap-devices (list (swap-space
                        (target "/mnt/swapfile")
                        (dependencies file-systems))))

  (name-service-switch %mdns-host-lookup-nss))
