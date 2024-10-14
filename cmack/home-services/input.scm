(define-module (cmack home-services input)
  #:use-module (gnu packages)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells))

(define (home-desktop-japanese-input-profile-service config)
  (map specification->package
       (list "fcitx5" "fcitx5-gtk" "fcitx5-gtk4" "fcitx5-anthy")))

(define (add-gtk3-wayland-input-environment config)
  (home-bash-extension
   (environment-variables
    ;; this appears necessary for IME on Firefox and Chromium
    '(("GUIX_GTK3_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache")))))

(define-public cmack-japanese-input-service-type
  (service-type (name 'cmack-japanese-input-service-type)
                  (extensions (list (service-extension home-profile-service-type
                                                       home-desktop-japanese-input-profile-service)
                                    (service-extension home-bash-service-type
                                                       add-gtk3-wayland-input-environment)))
                  (default-value #f)
                  (description "Configures Japanese Input using fcitx5")))
