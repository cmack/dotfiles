(define-module (cmack home-services media)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp))

(define (home-pipewire-profile-service config)
  (map specification->package (list "pipewire" "wireplumber")))

(define (home-pipewire-shepherd-service config)
  (list
   (shepherd-service
    (requirement '(dbus))
    (provision '(pipewire))
    (stop #~(make-kill-destructor))
    (start #~(make-forkexec-constructor
              (list "dbus-launch" "--exit-with-session"
                    #$(file-append pipewire "/bin/pipewire"))
              #:log-file (string-append
                          (or (getenv "XDG_LOG_HOME")
                              (format #f "~a/.local/var/log"
                                      (getenv "HOME")))
                          "/pipewire.log")
              #:environment-variables
              (append (list "DISABLE_RTKIT=1")
                      (default-environment-variables)))))
   (shepherd-service
    (requirement '(pipewire))
    (provision '(wireplumber))
    (stop #~(make-kill-destructor))
    (start #~(make-forkexec-constructor
              (list #$(file-append wireplumber "/bin/wireplumber"))
              #:log-file (string-append
                          (or (getenv "XDG_LOG_HOME")
                              (format #f "~a/.local/var/log"
                                      (getenv "HOME")))
                          "/wireplumber.log")
              #:environment-variables
              (append (list "DISABLE_RTKIT=1")
                      (default-environment-variables)))))
   (shepherd-service
    (requirement '(pipewire))
    (provision '(pipewire-pulse))
    (stop #~(make-kill-destructor))
    (start #~(make-forkexec-constructor
              (list #$(file-append pipewire "/bin/pipewire-pulse"))
              #:log-file (string-append
                          (or (getenv "XDG_LOG_HOME")
                              (format #f "~a/.local/var/log"
                                      (getenv "HOME")))
                          "/pipewire-pulse.log")
              #:environment-variables
              (append (list "DISABLE_RTKIT=1")
                      (default-environment-variables)))))))

(define-public home-pipewire-service-type
  (service-type (name 'home-pipewire)
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-pipewire-profile-service)
                       (service-extension
                        home-shepherd-service-type
                        home-pipewire-shepherd-service)))
                (default-value #f)
                (description "Configures and starts the Pipewire audio system")))

(define (home-desktop-portal-xdg-profile-service config)
  (map specification->package (list "xdg-desktop-portal"
                                    "xdg-desktop-portal-wlr")))

(define (home-desktop-portal-xdg-configuration-service config)
  `(("alsa/asoundrc"
     ,(mixed-text-file
       "asoundrc"
       #~(string-append
          "<"
          #$(file-append pipewire "/share/alsa/alsa.conf.d/50-pipewire.conf")
          ">\n<"
          #$(file-append pipewire "/share/alsa/alsa.conf.d/99-pipewire-default.conf")
          ">\n"
          "
pcm_type.pipewire {
  lib " #$(file-append pipewire "/lib/alsa-lib/libasound_module_pcm_pipewire.so")
  "
}
ctl_type.pipewire {
  lib " #$(file-append pipewire "/lib/alsa-lib/libasound_module_ctl_pipewire.so")
  "
}
"
  )))
    ("xdg-desktop-portal-wlr/config"
     ,(mixed-text-file
       "xdg-desktop-portal-wlr-config"
       #~(format #f "[screencast]
# output_name=
max_fps=30
chooser_cmd=~a -dmenu
chooser_type=dmenu"
                 #$(file-append rofi
                                "/bin/rofi"))))))

(define-public home-desktop-portal-xdg-service-type
  (service-type (name 'home-desktop-portal-xdg)
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-desktop-portal-xdg-profile-service)
                       (service-extension
                        home-xdg-configuration-files-service-type
                        home-desktop-portal-xdg-configuration-service)))
                (default-value #f)
                (description "Configures the XDG Desktop Portal WLR")))
