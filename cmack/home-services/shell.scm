(define-module (cmack home-services shell)
  #:use-module (gnu services)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services))

(define (home-desktop-environment-variables config)
  '(("PS1" . "\\n\\[\\e[1;2m\\]Time: \\[\\e[0;2m\\]\\D{%F %T}\\[\\e[0;1m\\] User: \\[\\e[0;3m\\]\\u\\[\\e[0m\\]@\\[\\e[3m\\]\\h\\[\\e[0;1m\\]λ \\nDir: \\[\\e[0m\\]\\w\\$ ")))

(define-public bash-fancy-prompt-service-type
  (service-type (name 'bash-fancy-prompt)
                (description "My shell prompt service")
                (extensions
                 (list (service-extension
                        home-environment-variables-service-type
                        home-desktop-environment-variables)))
                (default-value #f)))
