HASH		= standard cfarmhash farmhash cityhash murmurhash3 spookyv2
DATA		= $(HASH:=.dat)
CFLAGS  	= -Wall -Werror -Wpedantic -O3 -flto -std=c11
CXXFLAGS	= -Wall -Werror -Wpedantic -O3 -flto -std=c++11
BEGIN		= 1
INC		= 1
END		= 256

.PHONY: results clean

hash-function-benchmark.pdf: $(DATA)
	./graph.R

%.dat: %
	(echo "\"size\",\"rate\""; ./$^ $(BEGIN) $(END) $(INC) | tr -d , | awk '{printf "%d,%d\n",$$2,$$6}') > $@

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

clean:
	rm -f $(HASH) $(DATA)
