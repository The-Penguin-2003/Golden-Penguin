;;; Golden Penguin Second-Stage Bootloader ;;;
jmp _start_rm	; Immediately jump to start function

[BITS 16]	; Using 16-bit code

_start_rm:
	mov ah, 0x00	; BIOS set video mode function (int 0x10)
	mov al, 0x03	; 80x25 16-color text
	int 0x10	; BIOS disk interrupt

	mov ax, 0x9000	; Load 0x9000 into AX for stack space
	mov ss, ax	; Set stack segment
	mov sp, ax	; Set stack pointer to 0xFFFF

	mov ax, 0x100	; Set AX to base address
	mov ds, ax	; Set data segment

	mov si, stage2_welcome_msg	; Load address of stage2_welcome_msg into SI
	call puts			; Print

;; Functions
puts:
	mov ah, 0x0E	; BIOS teletype output function (int 0x10)

	.loop:
		lodsb		; Load current byte in SI into AL
		cmp al, 0	; Check if the end of the string has been reached
		je .done	; Return if the end of the string is reached
		int 0x10	; Print the character stored in AL
		jmp .loop	; Loop to next character

	.done:
		ret		; Return

;; Data
stage2_welcome_msg:
	db "Golden Penguin Second-Stage Bootloader",0xA,0xD,0

;; Magic
times 512-($-$$) db 0	; Fill the rest of the sector with 0s
