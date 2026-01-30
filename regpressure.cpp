#include <iostream>
#include <chrono>
#include <vector>

/**
 * Create register pressure by maintaining active variables 
 * that are all inter-dependent,forcing the compiler to 'spill' 
 * registers to the stack. 
 **/

void create_pressure(long iterations) {
    volatile long a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8, i=9, j=10,
                  k=11, l=12, m=13, n=14, o=15, p=16, q=17, r=18, s=19, t=20;

    for (long iter = 0; iter < iterations; ++iter) {
        a += b; b += c; c += d; d += e;
        e += f; f += g; g += h; h += i;
        i += j; j += k; k += l; l += m;
        m += n; n += o; o += p; p += q;
        q += r; r += s; s += t; t += a;

        if (a > 1000000) a %= 100;
    }

    std::cout << "Final value of t: 0x" << std::hex << t << std::endl;
}

int main() {
    
    const long total_iterations = 1500000000L;

    std::cout << "Starting high register pressure test for ~10 seconds..." << std::endl;
    
    auto start = std::chrono::high_resolution_clock::now();
    create_pressure(total_iterations);
    auto end = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double> diff = end - start;
    std::cout << "Execution time: " << diff.count() << " seconds." << std::endl;

    return 0;
}
