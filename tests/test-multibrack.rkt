#lang racket

(require rackunit)

(require peg)
(require peg/peg-result)

(define-peg multibrack
  (* (or multibrack-paren
         multibrack-square
         multibrack-brace
         multibrack-angle)))
(define-peg/tag multibrack-paren (and (drop #\() multibrack (drop #\))))
(define-peg/tag multibrack-square (and (drop #\[) multibrack (drop #\])))
(define-peg/tag multibrack-brace (and (drop #\{) multibrack (drop #\})))
(define-peg/tag multibrack-angle (and (drop #\<) multibrack (drop #\>)))

(check-equal? (peg-result->object (peg multibrack "([][{{}}{}]{}[])"))
              '((multibrack-paren (multibrack-square)
                                  (multibrack-square (multibrack-brace (multibrack-brace))
                                                     (multibrack-brace))
                                  (multibrack-brace)
                                  (multibrack-square))))
