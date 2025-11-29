# Define the target platform
TARGET := amiga

# Specify the architecture
ARCH := m68k
M68K_CPU := 68020

# Include necessary modules
MODULES += \
    app/shell

# Include the platform-specific makefile
include project/target/amiga.mk
