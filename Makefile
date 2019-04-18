#******************************************************************************
#
#    shuyunjia@outlook.com
#
#------------------------------------------------------------------------------
SRC_DIR = ./src/
BUILD_DIR = .
XLEN ?= 32
CCXLEN ?= riscv$(XLEN)-unknwon-elf-gcc
LDXLEN ?= riscv$(XLEN)-unknwon-elf-ld
DUMPERXLEN ?= riscv$(XLEN)-unknwon-elf-objdump

SOURCES = $(SRC_DIR)entry.S \
			$(SRC_DIR)main.c \
			$(SRC_DIR)plic.c \
			$(SRC_DIR)interrupt.c \
			$(SRC_DIR)syscalls.c 

INCLUDES = -I./include

##################################################################

TARGET = $(BUILD_DIR)/baremetal-example

LINKER = test.ld
LOG_FILE = pthread_log.txt

ISA ?= rv$(XLEN)imaf

ifeq ($(XLEN), 64)
	ABI ?= lp64
else
	ABI ?= ilp32
endif

N_PROC ?= 4

ifndef RISCV
$(error "[ ERROR ] - RISCV variable not set!")
endif

CC = $(RISCV)/bin/riscv$(XLEN)-unknown-elf-gcc
LD = $(RISCV)/bin/riscv$(XLEN)-unknown-elf-ld
DUMPER = $(RISCV)/bin/riscv$(XLEN)-unknown-elf-objdump
SIZE = $(RISCV)/bin/riscv$(XLEN)-unknown-elf-size
SPIKE = $(RISCV)/bin/spike

CFLAGS = -O1 -march=$(ISA) -mabi=$(ABI) -mcmodel=medany -ffreestanding -static -nostdlib -nostartfiles -lgcc $(INCLUDES) 
LDFLAGS = -T $(LINKER)


OBJS = $(SOURCES:.c=.o)
DEPS = $(SOURCES:.c=.d)

%.i : %.c
	#------>>  Preprocessing
	$(CC) -E $(CFLAGS) $(INCLUDES) $(SPIKE_SIMULATION) $< -o $@

%.S : %.c
	#------>>  Generating Assembly files
	$(CC) -S $(CFLAGS) $(INCLUDES) $(SPIKE_SIMULATION) $< -o $@

%.o : %.S %.c
	#------>>  Generating object file
	$(CC) -c $(CFLAGS) $(INCLUDES)  $(SPIKE_SIMULATION) $< -o $@
	
%.dump : %.out
	$(DUMPER) -S -D $<


.PHONY: compile-all
compile-all: $(OBJS)

.PHONY: build
build: all

.PHONY: all
all: $(TARGET).out

$(TARGET).out: compile-all
	$(CC) $(OBJS) $(CFLAGS) $(LDFLAGS) $(SPIKE_SIMULATION) -o $@
	$(SIZE) $@

.PHONY: sim
sim:
	@echo "-------------  Starting Spike ISS Simulation  -------------"
	$(SPIKE) -p$(N_PROC) --isa=$(ISA) $(TARGET).out 
	
.PHONY: debug
debug:
	@echo "-------------------  Starting Debugging  -------------------"
	@$(SPIKE) -d -p$(N_PROC) --isa=$(ISA) $(TARGET).out

.PHONY: log
log:
	@echo "-------------------  Starting Debugging  -------------------"
	@$(SPIKE) -p$(N_PROC) --isa=$(ISA) $(TARGET).out 2> $(LOG_FILE)


.PHONY: build-sim
build-sim: $(TARGET).out
	@echo ""
	@echo "-------------  Build done, starting simulation  -------------"
	@$(SPIKE) -p$(N_PROC) --isa=$(ISA)  $(TARGET).out

.PHONY: build-sim-cache
build-sim-cache: $(TARGET).out
#  --hartids=<a,b,...>   Explicitly specify hartids, default is 0,1,...
#  --ic=<S>:<W>:<B>      Instantiate a cache model with S sets,
#  --dc=<S>:<W>:<B>        W ways, and B-byte blocks (with S and
#  --l2=<S>:<W>:<B>        B both powers of 2).
#	DEFAULT lowRISC values
#  --ic=64:4:8      Instantiate a cache model with S sets,
#  --dc=64:4:8        W ways, and B-byte blocks (with S and
#  --l2=256:8:8        B both powers of 2).
	@echo ""
	@echo "-------------  Build done, starting simulation  -------------"
	@$(SPIKE) -p$(N_PROC) --isa=$(ISA) --ic=64:4:8 --dc=64:4:8 --l2=256:8:8 $(TARGET).out

.PHONY: clean
clean:
#	rm -f $(SRC_DIR)*.i $(SRC_DIR)*.s $(SRC_DIR)*.asm $(SRC_DIR)*.o $(SRC_DIR)*.d $(SRC_DIR)*.out $(SRC_DIR)*.map $(TARGET).out
	rm -f $(SRC_DIR)*.i $(SRC_DIR)*.asm $(SRC_DIR)*.o $(SRC_DIR)*.d $(SRC_DIR)*.out $(SRC_DIR)*.map $(TARGET).out
	
