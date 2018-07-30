(module anything racket
  (provide (all-defined-out))
  (require peg/peg)
  (begin
    (require "sexp-parser-expanded.rkt")
    (define-peg
     nt-char
     (or (range #\a #\z) (range #\A #\Z) (range #\0 #\9) #\_))
    (define-peg/tag
     nonterminal
     (and nt-char (* (or nt-char (or #\. #\/ #\-))) (! nt-char) SP))
    (define-peg/drop SP (* (or comment (or #\space #\tab #\newline))))
    (define-peg/drop comment (and "//" (* (and (! #\newline) (any-char)))))
    (define-peg/tag
     literal
     (and SQ
          (* (or (and BS (or #\' #\\)) (and (! (or #\' #\\)) (any-char))))
          SQ
          SP))
    (define-peg/drop SQ #\')
    (define-peg/drop BS #\\)
    (define-peg/tag
     charclass
     (and LB (? "^") (+ (or cc-range cc-escape cc-single)) RB SP))
    (define-peg/tag cc-range (and cc-char DASH cc-char))
    (define-peg/tag cc-escape (and BS (any-char)))
    (define-peg/tag cc-single cc-char)
    (define-peg cc-char (or (and (! cc-escape-char) (any-char)) "n" "t"))
    (define-peg cc-escape-char (or "[" "]" "-" "^" "\\" "n" "t"))
    (define-peg/drop LB "[")
    (define-peg/drop RB "]")
    (define-peg/drop DASH "-")
    (define-peg/tag
     identifier
     (and (or (range #\a #\z) (range #\A #\Z)) (* nt-char)))
    (define-peg/tag peg (and SP (* import) (+ grammar)))
    (define-peg/tag import (and "import" SP nonterminal ";" SP))
    (define-peg/tag
     grammar
     (and (and nonterminal (or "<--" "<-" "<") SP pattern)
          (? (and "->" SP s-exp SP))
          ";"
          SP))
    (define-peg/tag pattern (and alternative (* (and SLASH SP alternative))))
    (define-peg/tag alternative (+ (or named-expression expression)))
    (define-peg/tag
     named-expression
     (and identifier SP (drop ":") SP expression))
    (define-peg/tag
     expression
     (and (? (or #\! #\& #\~)) SP primary (? (and (or #\* #\+ #\?) SP))))
    (define-peg/tag
     primary
     (or (and "(" SP pattern ")" SP)
         (and "." SP)
         literal
         charclass
         nonterminal))
    (define-peg/drop SLASH "/")))