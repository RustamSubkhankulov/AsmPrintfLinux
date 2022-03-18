#test1:		obj/main1.o obj/test1.o  
#	ld -s obj/main1.o obj/test1.o -o test1 

test1:		obj/main1.o obj/test1.o  
	gcc obj/main1.o obj/test1.o -o test1 -no-pie

obj/main1.o:	src/main1.s 
	nasm  src/main1.s -l lst/main1.lst -f elf64 -o obj/main1.o

obj/test1.o: src/test1.cpp 
	gcc src/test1.cpp -o obj/test1.o -c 

