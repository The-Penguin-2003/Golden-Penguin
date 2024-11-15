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

	xor ax, ax		; Zero out AX
	xor ah, ah		; BIOS reset disk function (int 0x13)
	xor dl, dl		; Drive number (0=floppy)
	int 0x13		; BIOS disk interrupt

	jc disk_reset_failed	; If carry bit is set, the reset operation failed

	mov ax, BASE		; Set AX to BASE (0x100)
	mov es, ax		; Set extra segment to BASE
	xor bx, bx		; Zero out BX

	mov ah, 0x02		; BIOS read sectors function (int 0x13)
	mov al, SECTORS		; Number of sectors to read
	xor ch, ch		; Cylinder
	mov cl, 2		; Sector
	xor dh, dh		; Head
	mov dl, [boot_dev]	; Drive
	int 0x13		; BIOS disk interrupt

	jc disk_read_failed	; If carry bit is set, the read operation failed

	jmp dword BASE:0x0	; Far jump to second-stage bootloader

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

disk_reset_failed:
	mov si, reset_err_msg	; Load address of reset_err_msg into SI
	call puts		; Print
	jmp err			; Jump to error function

disk_read_failed:
	mov si, read_err_msg	; Load address of read_err_msg into SI
	call puts		; Print
	jmp err			; Jump to error function

err:
	mov si, load_err_msg	; Load address of load_err_msg into SI
	call puts		; Print
	jmp $			; Halt system

;; Data
welcome_msg:
	db "Welcome to the Golden Penguin first-stage bootloader!",0xA,0xD,0
keywait_msg:
	db "Press any key to enter second stage...",0xA,0xD,0
load_msg:
	db "Attempting to enter second stage...",0xA,0xD,0
reset_err_msg:
	db "ERROR: Failed To Reset Disk!",0xA,0xD,0
read_err_msg:
	db "ERROR: Failed To Read Disk!",0xA,0xD,0
load_err_msg:
	db "ERROR: Failed To Enter Second-Stage Bootloader!",0xA,0xD,0
boot_dev:
	db 0

;; Constants
BASE equ 0x100
SECTORS equ 0x20

;; Magic
times 510-($-$$) db 0	; Pad out 0s until 510th byte
dw 0xAA55		; Boot signature
