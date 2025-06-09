(define-module (cmack homes charlie)
  #:use-module (gnu packages)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services xdg)
  #:use-module (guix gexp)
  #:use-module (cmack home-services media)
  #:use-module (cmack home-services shell)
  #:use-module (cmack home-services input))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (specifications->packages (list "adwaita-icon-theme"
                                       "alacritty"
                                       "bind:utils"  ;for dig, nslookup,etc
                                       "borg"
                                       "byobu"
                                       "du-dust"
                                       "emacs-next-pgtk"
                                       "eza"
                                       "fd"
                                       "firefox"
                                       "font-adobe-source-code-pro"
                                       "font-adobe-source-han-sans"
                                       "font-awesome"
                                       "font-google-material-design-icons"
                                       "font-google-noto"
                                       "font-google-roboto"
                                       "font-ibm-plex"
                                       "font-ipa-ex"
                                       "fontconfig"
                                       "fuzzel"
                                       "gnome-themes-extra"
                                       "gnupg"
                                       "grim"
                                       "gsettings-desktop-schemas"
                                       "hackneyed-x11-cursors"
                                       "hicolor-icon-theme"
                                       "htop"
                                       "hunspell"
                                       "hunspell-dict-en-us"
                                       "jq"
                                       ;; "kitty"
                                       "kanshi"
                                       "lsof"
                                       "mako"
                                       "pavucontrol"
                                       "pinentry-rofi"
                                       "pipewire" ;cli tools access
                                       "reptyr"
                                       "ripgrep"
                                       "rofi-wayland"
                                       "rsync"
                                       "shellcheck"
                                       "slurp"
                                       "sqlite"
                                       "stow"
                                       "sway"
                                       "swaybg"
                                       "swayidle"
                                       "tmux"
                                       "tree-sitter-css"
                                       "tree-sitter-javascript"
                                       "tree-sitter-julia"
                                       "tree-sitter-php"
                                       "tree-sitter-python"
                                       "tree-sitter-scheme"
                                       ;; "tree-sitter-yaml"
                                       ;; "tree-sitter-tsx"
                                       "unzip"
                                       "vlc"
                                       "waybar"
                                       "wireplumber" ;needed for cli tools
                                       "wl-clipboard"
                                       "wf-recorder"
                                       "xcursor-themes"
                                       "xdg-user-dirs"
                                       "xdg-utils"
                                       "xournalpp"
                                       "steam")))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (append (list (service home-bash-service-type
                          (home-bash-configuration
                           (environment-variables '(("XDG_CURRENT_DESKTOP" . "sway")
                                                    ("XDG_SESSION_TYPE" . "wayland")
                                                    ;; FIXME: Should be in feature-pipewire
                                                    ("RTC_USE_PIPEWIRE" . "true")
                                                    ("SDL_VIDEODRIVER" . "wayland")
                                                    ("MOZ_ENABLE_WAYLAND" . "1")
                                                    ("CLUTTER_BACKEND" . "wayland")
                                                    ("ELM_ENGINE" . "wayland_egl")
                                                    ("ECORE_EVAS_ENGINE" . "wayland-egl")
                                                    ("QT_QPA_PLATFORM" . "wayland-egl")
                                                    ("_JAVA_AWT_WM_NONREPARENTING" . "1")))))
                 (service bash-fancy-prompt-service-type)
                 (service home-xdg-user-directories-service-type)
                 (service home-dbus-service-type)
                 (service home-pipewire-service-type)
                 (service home-desktop-portal-xdg-service-type)
                 (service home-gpg-agent-service-type
                          (home-gpg-agent-configuration (pinentry-program (file-append
                                                                           pinentry-rofi
                                                                           "/bin/pinentry-rofi"))
                                                        (ssh-support? #t)))

                 (service cmack-japanese-input-service-type))
           %base-home-services)))
