;;; Golden Penguin Bootloader ;;;

[ORG 0]		; Start the code at 0
[BITS 16]	; Using 16-bit code

;; Bootloader Entry Point
_start:
	mov ah, 0x00	; BIOS set video mode function (int 0x10)
	mov al, 0x03	; 80x25 16-color text
	int 0x10	; BIOS video interrupt

	cli		; Disable interrupts
	mov ax, 0x7C0	; Set AX to address of boot code
	mov ds, ax	; Data segment
	mov es, ax	; Extra segment

	xor ax, ax	; Zero out AX
	mov ss, ax	; Stack segment
	sti		; Enable interrupts

	mov si, welcome_msg	; Move address of welcome_msg into SI
	call puts		; Call the puts function

	mov si, keywait_msg	; Move address of keywait_msg into SI
	call puts		; Print

	call keywait		; Wait for a key

	mov si, load_msg	; Move address of load_msg into SI
	call puts		; Print

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

keywait:
	mov al, 0xD2	; Load keyboard command 0xD2 into AL
	out 0x64, al	; Send command to keyboard command port

	mov al, 0x80	; Load key release scancode into AL
	out 0x60, al	; Write byte to keyboard data port

	.keyup:
		in al, 0x60		; Read byte from keyboard output buffer
		and al, 0b10000000	; If bit 7 is set, a key release happened
		jnz .keyup		; Continue looping if bit 7 is not set

	.keydn:
		in al, 0x60	; Read scancode from output buffer
		ret		; Return

;; Data
welcome_msg:
	db "Welcome to the Golden Penguin bootloader!",0xA,0xD,0
keywait_msg:
	db "Press any key to load kernel...",0xA,0xD,0
load_msg:
	db "Attempting to load kernel...",0

;; Magic
times 510-($-$$) db 0	; Pad out 0s until 510th byte
dw 0xAA55		; Boot signature
