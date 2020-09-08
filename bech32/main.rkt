#lang racket

(provide bech32-decode)

(define (bech32-hrp-expand hrp)
  (define xs (bytes->list (string->bytes/utf-8 hrp)))
  (append
   (for/list ([x xs]) (arithmetic-shift x -5))
   '(0)
   (for/list ([x xs]) (bitwise-and x 31))))

(define (bech32-polymod xs)
  (define gs (list #x3b6a57b2 #x26508e6d #x1ea119fa #x3d4233dd #x2a1462b3))
  (for/fold ([chk 1])
            ([x xs])
    (define top (arithmetic-shift chk -25))
    (define chk-new (bitwise-xor (arithmetic-shift (bitwise-and chk #x1ffffff) 5) x))
    (bitwise-xor
     chk-new
     (for/fold ([v 0])
               ([g gs]
                [i (in-naturals)])
       (bitwise-xor v
                    (if (= 1 (bitwise-and (arithmetic-shift top (- i)) #x1)) g 0))))))

(define (bech32-decode-bits data)
  (define-values (_1 _2 res)
    (for/fold ([cur 0]
               [i 0]
               [res empty])
              ([x data])
      (define ni (+ i 5))
      (define nc (bitwise-ior (arithmetic-shift cur 5) x))
      (if (>= ni 8)
          (values (bitwise-and nc (arithmetic-shift #xFF (- ni 16)))
                  (- ni 8)
                  (cons (arithmetic-shift nc (- 8 ni)) res))
          (values nc ni res))))
  (list->bytes (reverse res)))

(define/contract (bech32-decode str)
  (-> string? bytes?)
  (define alphabet
    (for/hash ([c "qpzry9x8gf2tvdw0s3jn54khce6mua7l"]
               [i (in-naturals)])
      (values c i)))
  (match (string-downcase str)
    [(regexp #rx"^(bc|bcrt|tb)1(.*)$" (list _ hrp encoded-data))
     (define data-with-check
       (for/list ([c encoded-data])
         (hash-ref alphabet c (thunk (error "Invalid char in bech32 string")))))
     (define polymod-res (bech32-polymod (append (bech32-hrp-expand hrp) data-with-check)))
     (unless (= polymod-res 1)
       (error "Invalid checksum"))
     (define data (take data-with-check (- (length data-with-check) 6)))
     (unless (= (first data) 0)
       (error "Nonzero witness version"))
     (bech32-decode-bits (rest data))]
    [_ (error "Invalid bech32 address prefix")]))
