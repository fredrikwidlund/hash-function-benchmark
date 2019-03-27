HASH		= crc32 crc64 standard cfarmhash farmhash cityhash murmurhash3 spookyv2 clhash
DATA		= $(HASH:=.csv)
CFLAGS  	= -Wall -Werror -Wpedantic -O3 -flto -std=c11 -fPIC -msse4.2 -mpclmul -march=native -funroll-loops
CXXFLAGS	= -Wall -Werror -Wpedantic -O3 -flto -std=c++11 -fPIC -msse4.2 -mpclmul -march=native -funroll-loops
BEGIN		= 1
INC		= 1
END		= 256

.PHONY: results clean

hash-function-benchmark.pdf: $(DATA)
	./graph.R

%.csv: %
	(echo "\"size\",\"rate\""; ./$^ $(BEGIN) $(END) $(INC) | tr -d , | awk '{printf "%d,%d\n",$$2,$$6}') > $@

crc32: crc32.cc support/crc32.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^ -I support
	
crc64: crc64.cc
	$(CXX) $(CXXFLAGS) -o $@ $^ -I support
	
standard: standard.cc
	$(CXX) $(CXXFLAGS) -o $@ $^ -I support

cfarmhash: cfarmhash.c support/cfarmhash.c
	$(CC) $(CFLAGS) -o $@ $^ -I support

farmhash: farmhash.cc support/farmhash.cc
	$(CXX) $(CXXFLAGS) -o $@ $^ -I support

cityhash: cityhash.cc support/city.cc
	$(CXX) $(CXXFLAGS) -o $@ $^ -I support

murmurhash3: murmurhash3.cc support/MurmurHash3.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^ -I support

spookyv2: spookyv2.cc support/SpookyV2.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^ -I support

clhash: clhash.c support/clhash.c
	# clhash wants very specific flags
	$(CC) $(CFLAGS) -std=c99 \
		-Wstrict-overflow \
		-Wstrict-aliasing \
		-Wextra \
		-Wshadow \
		-o $@ $^ -I support
overall: support/cfarmhash.h support/cfarmhash.c support/MurmurHash3.cpp support/MurmurHash3.h support/clhash.h support/clhash.c support/crc32.cpp overall.cc
	$(CXX) -O3 -o overall overall.cc -march=native -Wall -Wextra
	./overall

clean:
	rm -f $(HASH) $(DATA)
