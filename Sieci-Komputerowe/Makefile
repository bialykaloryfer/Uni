CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra

TARGET = traceroute
SRC = source.cpp

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)

clean:
	rm -f $(TARGET)
