all: 
	gcc  -o cPiMC  PiMC.c
	nvcc -o cuPiMC  PiMC.cu
	gcc -o SpeedUp  SpeedUp.c
run: all
	./cPiMC 10
	./cuPiMC 10
	./cPiMC 100
	./cuPiMC 100
	./cPiMC 1000
	./cuPiMC 1000
	./cPiMC 10000
	./cuPiMC 10000
	./cPiMC 100000
	./cuPiMC 100000
	./cPiMC 1000000
	./cuPiMC 1000000
	./cPiMC 10000000
	./cuPiMC 10000000
	./cPiMC 100000000
	./cuPiMC 100000000
	./cPiMC 1000000000
	./cuPiMC 1000000000
	./SpeedUp c_exec_time.csv cu_exec_time.csv
	
clean:
	rm -f cPiMC
	rm -f cuPiMC
	rm -f c_exec_time.csv
	rm -f cu_exec_time.csv
	rm -f SpeedUp.csv
	rm -f SpeedUp
