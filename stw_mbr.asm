%include "stw_mbr_header.inc"
org 07c00h
jmp LABEL_BEGIN

[section .gdt]
    LABEL_GDT: Descriptor   0,  0, 0
    LABEL_DESC_CODE32: Descriptor   0,  SegCode32Len - 1, DA_C+DA_32
    LABEL_DESC_VIDEO:  Descriptor   0B8000h,    0ffffh, DA_DRW
;GDT结束

GdtLen equ $-LABEL_GDT ;gdt长度
GdtPtr dw GdtLen-1  ;界限

SelectorCode32 equ LABEL_DESC_CODE32 - LABEL_GDT
SelectorVideo equ LABEL_DESC_VIDEO - LABEL_GDT

[section .s16]
[bits 16]
LABEL_BEGIN:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0100h

    ;初始化32位代码描述符
    xor eax, eax
    mov ax, cs
    shl eax, 4
    add eax, LABEL_DESC_CODE32
    mov word [LABEL_DESC_CODE32+2], ax
    shr eax, 16
    mov byte [LABEL_DESC_CODE32+4], al
    mov byte [LABEL_DESC_CODE32+7], ah
    ;准备GDTR
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_GDT
    mov dword [GdtPtr+2], eax
    
    ;load GDTR
    lgdt [GdtPtr]

    ;关中断
    cli

    in al, 92h
    or al, 00000010b
    out 92h, al

    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ;进入保护模式
    jmp dword SelectorCode32:0
;end of section .s16

[section .s32]
[bits 32]

LABEL_SEG_CODE32:
    mov ax, SelectorVideo
    mov gs, ax
    mov edi, (80*11+79)*2
    mov ah, 0Ch,
    mov al, 'P'
    mov [gs:edi], ax
    jmp $

SegCode32Len equ $ - LABEL_SEG_CODE32
;end of section .s32

times 510-($-$$) db 0
dw 0x55aa