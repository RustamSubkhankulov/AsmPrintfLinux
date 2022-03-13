
OBJAsm = obj/main.o obj/RsPrint.o obj/RsItoa.o obj/PrintUnitTests.o

OBJC   = obj/RsPrint.o obj/RsItoa.o

objAsm: 	$(OBJAsm) 

objC:		$(OBJC) src/CPrintTest.cpp 

PrintAsm: 	objAsm 
		ld -s $(OBJAsm) -o main 

PrintC:		objC 
		gcc $(OBJC) src/CPrintTest.cpp -o CPrintTest -no-pie  

obj/main.o: 		main.s
		nasm main.s -l lst/main.lst -f elf64 -o obj/main.o

obj/RsPrint.o: 		src/RsPrint.s
		nasm src/RsPrint.s -l lst/RsPrint.lst -f elf64 -o obj/RsPrint.o 

obj/RsItoa.o:		src/RsItoa.s
		nasm src/RsItoa.s -l lst/RsItoa.lst -f elf64 -o obj/RsItoa.o 

obj/PrintUnitTests.o: src/PrintUnitTests.s 
		nasm src/PrintUnitTests.s -l lst/PrintUnitTests.lst -f elf64 -o obj/PrintUnitTests.o
