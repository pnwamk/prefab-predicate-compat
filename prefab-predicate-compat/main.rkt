#lang typed/racket/base

(require (for-syntax typed/racket/base
                     version/utils
                     racket/syntax))

;; (define-backwards-compatible-prefab-predicate predicate-name prefab-name)
;;
;; In Racket versions <= 6.90.0.28,
;; (define-backwards-compatible-prefab-predicate Foo? foo)
;; expands to: (define Foo? foo?)
;;
;; This is not sound... but it's not any worse than just using foo (which is all users
;; have been provided to far).
;;
;; In Racket versions > 6.90.0.28,
;; (define-backwards-compatible-prefab-predicate Foo? foo)
;; expands to:
;; (define-predicate Foo? foo)
;;
;; Which _is sound_, and generates a predicate for the type described by `foo`
;; if possible (i.e. it will work for any immutable prefab type `foo` that has
;; first-order data in its fields).

(provide define-backwards-compatible-flat-prefab-predicate)

(define-syntax (define-backwards-compatible-flat-prefab-predicate stx)
  (syntax-case stx ()
    [(_ predicate-name prefab-name)
     (let ([major-version (string->number (substring (version) 0 1))]
           [minor-version (string->number (substring (version) 2 4))])
       (cond
         [(version<? "6.90.0.28" (version))
          ;; At this point in Typed Racket we can generate predicates
          ;; for prefabs and so we will just do exactly that using `define-predicate`.
          ;; Note: This is sound as it actually checks the field values.
          (syntax/loc stx
            (define-predicate predicate-name prefab-name))]
         [else
          ;; Prior to "6.90.0.29" we could not generate predicates for prefab structs
          ;; AND the predicates for prefabs were unsound. For simplicity and backwards compatibility,
          ;; we'll just use that unsound predicate. This is at least no _worse_ than things already
          ;; were for old code, and if the code is loaded in a newer version of Racket it will
          ;; instead get the sound predicate (defined above).
          (with-syntax ([orig-predicate (format-id #'predicate-name "~a?" (syntax-e #'prefab-name))])
            (syntax/loc stx
              (define predicate-name : (-> Any Boolean : prefab-name) orig-predicate)))]))]))


(module+ test
  (struct point ([x : Real] [y : Real]) #:prefab)
  (define-backwards-compatible-flat-prefab-predicate Point? point)

  (: zero-x (-> Any point))
  (define (zero-x p)
    (cond
      [(Point? p) (point 0 (point-y p))]
      [else (point 0 0)])))
