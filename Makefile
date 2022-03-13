
all: 		exe

OBJ = obj/main.o obj/RsPrint.o obj/RsItoa.o obj/PrintUnitTests.o

obj/main.o: 		main.s
		nasm main.s -l lst/main.lst -f elf64 -o obj/main.o

obj/RsPrint.o: 		src/RsPrint.s
		nasm src/RsPrint.s -l lst/RsPrint.lst -f elf64 -o obj/RsPrint.o

obj/RsItoa.o:		src/RsItoa.s
		nasm src/RsItoa.s -l lst/RsItoa.lst -f elf64 -o obj/RsItoa.o

obj/PrintUnitTests.o: src/PrintUnitTests.s 
		nasm src/PrintUnitTests.s -l lst/PrintUnitTests.lst -f elf64 -o obj/PrintUnitTests.o

obj: 	$(OBJ) 

exe: 	obj 
		ld -s $(OBJ) -o main 