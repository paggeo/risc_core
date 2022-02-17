CC = gcc
CFLAGS = -Wall -Wextra 

## Remove some warnings.
CFLAGS += -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function
# RES=-DPRINT_RESULTS

all: float_point_unit

## Which linked list implementation to use?
LL_FILE = 

## Additional source files
SRC_FILES = 

#$(CC) $(CFLAGS) $^ -o $@
float_point_unit: float_point_unit.c ${LL_FILE} ${SRC_FILES}
	$(CC) $^ -o $@


clean:
	rm -f float_point_unit
