; PNG headers

PNG_SIG

; Image Header
istruc chunk
    at chunk.Length,    _dd IHDR_size
    at chunk.ChunkType, db 'IHDR'
iend
;ChunkData
istruc IHDR
    at IHDR.Width,              _dd 335
    at IHDR.Height,             _dd 312
    at IHDR.Bit_depth,          db 8
    at IHDR.Color_type,         db 4 ; grayscale + alpha
;   at IHDR.Compression_method, db 0 ; the only standard one
;   at IHDR.Filter_method,      db 0 ; none
;   at IHDR.Interlace_method,   db 0 ; sequentially - no interlacing
iend
; missing the CRC, because we need to define an offset only once