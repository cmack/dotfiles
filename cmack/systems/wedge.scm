;; This is an operating system configuration generated
;; by the graphical installer.

(use-modules (gnu)
             (srfi srfi-1)
             ;; (gnu packages emacs) ; commented removable?
             (gnu packages linux)
             ;; (gnu packages version-control)
             ;; (gnu packages vim)
             ;; (gnu packages wm)
             (nongnu packages linux)
             (nongnu system linux-initrd))

(use-service-modules cups desktop networking ssh sound xorg avahi)

(define %wedge-desktop-services
  (cons*
   (service openssh-service-type)
   (service screen-locker-service-type
            (screen-locker-configuration
             (name "swaylock")
             (program (file-append (specification->package "swaylock")
                                   "/bin/swaylock"))
             (allow-empty-password? #f)
             (using-pam? #t)
             (using-setuid? #f)))

   (service sane-service-type)
   (service cups-service-type
            (cups-configuration
             (web-interface? #t)))

   ;; (service screen-locker-service-type
   ;;          (screen-locker-configuration "swaylock"
   ;;                                       (file-append swaylock "/bin/swaylock")
   ;;                                       #f))
   ;; (service screen-locker-service-type kbd "vlock")

   ;; Add udev rules to enable PipeWire use
   (udev-rules-service 'pipewire-add-udev-rules pipewire)
   (remove (lambda (service)
             (let ((type (service-kind service)))
               (memq type (list
                           gdm-service-type
                           screen-locker-service-type))))
           (modify-services
            %desktop-services
            (guix-service-type config => (guix-configuration
                                          (inherit config)
                                          (substitute-urls
                                           (cons* "https://substitutes.nonguix.org"
                                                  %default-substitute-urls))
                                          (authorized-keys
                                           (cons* (local-file "./non-guix.pub")
                                                  %default-authorized-guix-keys))))))))

(operating-system
 (kernel linux)
 (kernel-loadable-modules (list v4l2loopback-linux-module))
 (initrd microcode-initrd)
 (firmware (list linux-firmware amdgpu-firmware))
 (locale "en_US.utf8")
 (timezone "America/Chicago")
 (keyboard-layout (keyboard-layout "us" #:options '("ctrl:swapcaps")))

 (host-name "wedge")

 (users (cons* (user-account
                (name "charlie")
                (comment "Charlie")
                (group "users")
                (home-directory "/home/charlie")
                (supplementary-groups
                 '("wheel" "netdev" "audio" "video" "input" "kvm" "lp" "lpadmin" "tty")))
               %base-user-accounts))
 (packages
  (append (map specification->package
               (list "git"
                     "emacs"
                     "vim"
                     "sway"
                     "swayidle"
                     "swaylock"))
          %base-packages))

 (services %wedge-desktop-services)

 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets '("/boot/efi"))
   (keyboard-layout keyboard-layout)))

 (mapped-devices
  (list (mapped-device
         (source
          (uuid "938efa41-317a-4f08-b45c-d346ce83534e"))
         (target "cryptroot")
         (type luks-device-mapping))))

 (file-systems
  (cons* (file-system
          (mount-point "/boot/efi")
          (device (uuid "1FCB-F126" 'fat32))
          (type "vfat"))
         (file-system
          (mount-point "/")
          (device "/dev/mapper/cryptroot")
          (type "ext4")
          (dependencies mapped-devices))
         %base-file-systems))

 ;; allow .local
 (name-service-switch %mdns-host-lookup-nss))
