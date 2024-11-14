;;; Golden Penguin Bootloader ;;;

[ORG 0]		; Start the code at 0
[BITS 16]	; Using 16-bit code

;; Bootloader Entry Point
_start:
	cli		; Disable interrupts
	mov ax, 0x7C0	; Set AX to address of boot code
	mov ds, ax	; Data segment
	mov es, ax	; Extra segment

	xor ax, ax	; Zero out AX
	mov ss, ax	; Stack segment
	sti		; Enable interrupts

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
