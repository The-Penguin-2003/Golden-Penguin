;;; Golden Penguin Bootloader ;;;

[ORG 0x7C00]	; Bootloader code starts at memory address 0x7C00
[BITS 16]	; Using 16-bit code

;; Bootloader Entry Point
_start:
	mov si, welcome_msg	; Move address of welcome_msg into SI
	call puts		; Call the puts function
	jmp $			; Infinite loop

;; Functions
puts:
	xor bx, bx	; Clear BX so it can be used as a counter

	.loop:
		lodsb		; Load byte at address SI into AL, increment SI
		cmp al, 0	; Check if the end of the string has been reached
		je .done	; If AL=0, finish printing
		call putc	; Print character stored in AL
		jmp .loop

	.done:
		ret	; Return

putc:
	mov ah, 0x0E	; BIOS teletype output function (int 0x10)
	int 0x10	; BIOS video interrupt
	ret		; Return

;; Data
welcome_msg:
	db "Golden Penguin",0

;; Magic
times 510-($-$$) db 0	; Pad out 0s until 510th byte
dw 0xAA55		; Boot signature
