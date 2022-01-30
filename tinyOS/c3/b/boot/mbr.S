; main boot record
%include "boot.inc"
SECTION MBR vstart=0x7c00
    mov AX, CS
    MOV DS, AX
    MOV ES, AX
    MOV SS, AX
    MOV FS, AX
    MOV SP, 0X7C00
    MOV AX, 0XB800
    MOV GS, AX

; clear screen
    MOV AX, 0600H
    MOV BX, 0700H
    MOV CX, 0      ;(0, 0)
    MOV DX, 184FH  ;(80,25)
    INT 10H

; output string
    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4
    
    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4
    
    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0xA4
    
    mov byte [gs:0x06], 'B'
    mov byte [gs:0x07], 0xA4
    
    mov byte [gs:0x08], 'R'
    mov byte [gs:0x09], 0xA4

    MOV EAX, LOADER_START_SECTOR
    MOV BX, LOADER_BASE_ADDR
    MOV CX, 1
    CALL RD_DISK_M_16

    JMP LOADER_BASE_ADDR

; read n sectors of disk
RD_DISK_M_16:

; set the number of sector to read
    MOV ESI, EAX
    MOV DI, CX
    MOV DX, 0X1F2
    MOV AL, CL
    OUT DX, AL

    MOV EAX, ESI

; set LBA
    MOV DX, 0X1F3
    OUT DX, AL

    MOV CL, 8
    SHR EAX, CL
    MOV DX, 0X1F4
    OUT DX, AL
    
    SHR EAX, CL
    MOV DX, 0X1F5
    OUT DX, AL

    SHR EAX, CL
    AND AL, 0X0F
    OR AL, 0XE0
    MOV DX, 0X1F6
    OUT DX, AL

    MOV DX, 0X1F7
    MOV AL, 0X20
    OUT DX, AL

.NOT_READY:
    nop
    IN AL, DX
    AND AL, 0X88
    CMP AL, 0X08
    JNZ .NOT_READY

    MOV AX, DI
    MOV DX, 256
    MUL DX
    MOV CX, AX

    MOV DX, 0X1F0
.GO_ON_READ:
    IN AX, DX
    MOV [BX], AX
    ADD BX, 2
    LOOP .GO_ON_READ
    RET

    TIMES 510-($-$$) DB 0
    DB 0X55, 0XAA