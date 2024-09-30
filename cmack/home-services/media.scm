(define-module (cmack home-services media)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp))

(define (home-desktop-portal-xdg-profile-service config)
  (map specification->package
       (list "xdg-desktop-portal" "xdg-desktop-portal-wlr")))

(define (home-desktop-portal-xdg-configuration-service config)
  `(("xdg-desktop-portal-wlr/config" ,(mixed-text-file
                                       "xdg-desktop-portal-wlr-config"
                                       #~(format #f "[screencast]
# output_name=
max_fps=30

chooser_cmd=~a --dmenu
chooser_type=dmenu"
                                                 #$(file-append fuzzel
                                                    "/bin/fuzzel"))))))

(define-public home-desktop-portal-xdg-service-type
  (service-type (name 'home-desktop-portal-xdg)
                (extensions (list (service-extension home-profile-service-type
                                   home-desktop-portal-xdg-profile-service)
                                  (service-extension
                                   home-xdg-configuration-files-service-type
                                   home-desktop-portal-xdg-configuration-service)))
                (default-value #f)
                (description "Configures the XDG Desktop Portal WLR")))
