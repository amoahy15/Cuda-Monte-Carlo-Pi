#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char** argv) {
    if (argc != 2) {
        printf("Invalid Argument\n");
        return 1;
    }
    
    int iterations = atoi(argv[1]);
    if (iterations <= 0) {
        printf("Error: Number of iterations must be a positive integer.\n");
        return 1;
    }

    
    srand(time(NULL));
    int inside = 0;
    double x;
    double y;
    clock_t start = clock(); // Start timing
    for (int i = 0; i < iterations; i++) {
        x = (double)rand() / RAND_MAX;
        y = (double)rand() / RAND_MAX;
        if (x*x + y*y <= 1.0) {
            inside++;
        }
    }
    clock_t end = clock(); // Stop timing
    
    double pi = 4.0 * inside / iterations;
    double elapsedTime = (double)(end - start) / CLOCKS_PER_SEC; // Calculate time taken
    
    FILE *fp = fopen("c_exec_time.csv", "a"); 
    if (fp == NULL) {
        printf("Error opening file\n");
        return 1;
    }
    
    fprintf(fp, "%.8f,%d\n", elapsedTime, iterations);
    fclose(fp); 
    
    printf("Estimate of pi using C: %.8f\n", pi);
    printf("Time taken by program: %f seconds\n", elapsedTime); // Print time taken
    
    return 0;
}
