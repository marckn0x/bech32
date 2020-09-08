#lang racket

(require rackunit
         (only-in file/sha1 hex-string->bytes)
         "main.rkt")

(define decode-cases
  '(("BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4"
     "751e76e8199196d454941c45d1b3a323f1433bd6")
    ("tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7"
     "1863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262")
    ("tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy"
     "000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433")))

(for ([p decode-cases])
  (check-equal? (bech32-decode (first p))
                (hex-string->bytes (second p))))
