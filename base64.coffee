###
"URL-safe" Base64 Codec, by Jacob Rus

Input to Base64.encode and output from Base64.decode is a string where each
character encodes one byte.

This library happily strips off as many trailing '=' as are included in the
input to 'decode', and doesn't worry whether its length is an even multiple
of 4. It does not include trailing '=' in its own output. It uses the
'URL safe' base64 alphabet, where the last two characters are '-' and '_'.
###

Base64 = do ->
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
    trailingPad = '='
    padChar = alphabet.substr -1

    decodeMap = {}
    (decodeMap[char] = idx) for char, idx in alphabet

    alphabet_inverse = new RegExp '[^' + (alphabet.replace '-', '\\-') + ']'
    high_byte_character = /[^\x00-\xFF]/

    encode = (bytes) ->
        if high_byte_character.test bytes
            throw new Error 'Input contains out-of-range characters.'
        padding = '\x00\x00\x00'.slice (bytes.length % 3) or 3
        bytes += padding # pad with null bytes
        out_array = []
        for i in [0...bytes.length] by 3
            newchars = (
                ((bytes.charCodeAt i)   << 0o20) +
                ((bytes.charCodeAt i+1) << 0o10) +
                ((bytes.charCodeAt i+2)))
            out_array.push(
                (alphabet.charAt (newchars >> 18) & 0o77),
                (alphabet.charAt (newchars >> 12) & 0o77),
                (alphabet.charAt (newchars >> 6)  & 0o77),
                (alphabet.charAt (newchars) & 0o77))

        out_array.length -= padding.length
        out_array.join ''

    decode = (b64text) ->
        b64text = b64text.replace /\s/g, '' # kill whitespace

        # strip trailing pad characters from input; # XXX maybe some better way?
        i = b64text.length
        while (b64text.charAt --i) == trailingPad then # pass
        b64text = b64text.slice 0, i + 1

        if alphabet_inverse.test b64text
            throw new Error 'Input contains out-of-range characters.'

        padLength = 4 - ((b64text.length % 4) or 4)
        padding = (new Array padLength + 1).join padChar

        b64text += padding # pad with last letter of alphabet

        out_array = []
        length = i + padLength + 1 # length of b64text
        for i in [0..length] by 4
            newchars = (
                (decodeMap[b64text.charAt i]   << 18) +
                (decodeMap[b64text.charAt i+1] << 12) +
                (decodeMap[b64text.charAt i+2] << 6)  +
                (decodeMap[b64text.charAt i+3]))
            out_array.push(
                (newchars >> 0o20) & 0xFF,
                (newchars >> 0o10) & 0xFF, 
                (newchars)         & 0xFF)

        length = (out_array.length -= padLength)
        String.fromCharCode out_array...

    {encode, decode}

###
Copyright (c) 2009-2012 Jacob Rus

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
###