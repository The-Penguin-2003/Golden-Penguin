.PHONY: all disk run clean

AS = nasm
ASFLAGS = -f bin

VM = qemu-system-x86_64
VMFLAGS = -machine pc -cpu 486 -m 8M -fda GoldenPenguin.img -hda GoldenPenguin.hdd -vga std -net none -monitor stdio -display sdl -rtc base=localtime -boot order=a

all: disk run

disk: boot/boot.o boot/loader.o
	qemu-img create -f qcow2 GoldenPenguin.hdd 2G
	dd if=/dev/zero of=GoldenPenguin.img bs=512 count=2880
	dd if=boot/boot.o of=GoldenPenguin.img conv=notrunc
	dd if=boot/loader.o of=GoldenPenguin.img seek=1 conv=notrunc

boot/%.o: boot/%.asm
	$(AS) $(ASFLAGS) -o $@ $<

run: GoldenPenguin.img GoldenPenguin.hdd
	$(VM) $(VMFLAGS)

clean:
	rm -f boot/*.o *.hdd *.img
