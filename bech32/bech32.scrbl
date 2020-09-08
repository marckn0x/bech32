#lang scribble/manual

@(require (for-label racket))

@title{Bech32}

@author[(author+email "Marc Burns" "marc@kn0x.io")]

@defmodule[bech32]

Provides
@hyperlink["https://en.bitcoin.it/wiki/BIP_0173"]{Bech32}
encoding and decoding functions.

@defproc[(bech32-decode [str string?]) bytes?]{
  Decodes bech32 string @racketfont{str} to bytes.
}
