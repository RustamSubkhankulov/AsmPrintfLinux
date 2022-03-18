#test1:		obj/main1.o obj/test1.o  
#	ld -s obj/main1.o obj/test1.o -o test1 

test1:		obj/main1.o obj/test1.o  
	gcc obj/main1.o obj/test1.o -o test1 -no-pie

obj/main1.o:	src/main1.s 
	nasm  src/main1.s -l lst/main1.lst -f elf64 -o obj/main1.o

obj/test1.o: src/test1.cpp 
	gcc src/test1.cpp -o obj/test1.o -c 


test2:		obj/main2.o obj/test2.o  
	ld -s obj/main2.o obj/test2.o -o test2 /lib/x86_64-linux-gnu/libc.so -I /lib64/ld-linux-x86-64.so.2

obj/main2.o:	src/main2.s 
	nasm  src/main2.s -l lst/main2.lst -f elf64 -o obj/main2.o

obj/test2.o: src/test2.cpp 
	gcc src/test2.cpp -o obj/test2.o -c 

