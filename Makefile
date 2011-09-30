EXE = rsa_test merkle_hellman_test
ADA_VERSION = -gnat05
RSA_SRC = RSA.adb RSA_Test.adb
SRC = Number_Theory_Tools.adb 
MERKLE_HELLMAN = Merkle_Hellman_Test.adb Merkle_Hellman.adb
FLAGS = -gnato -gnatwa -fstack-check
#FLAGS = 
all: rsa merkle-hellman


rsa: $(SRC) RSA.adb
	gnatmake $(ADA_VERSION) $(FLAGS) $(SRC) $(RSA_SRC)

merkle-hellman: $(SRC) Merkle_Hellman.adb
	gnatmake $(ADA_VERSION) $(FLAGS) $(SRC) $(MERKLE_HELLMAN)

ada83: 
	gnatmake -gnat83  $(FLAGS) $(SRC)

ada95: 
	gnatmake -gnat95  $(FLAGS) $(SRC)

ada2005: 
	gnatmake -gnat05  $(FLAGS) $(SRC)

ada2012: 
	gnatmake -gnat12  $(FLAGS) $(SRC)

clean:
	rm *.ali *~ *.o $(EXE)