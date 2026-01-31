# regpressure/regdetect_v1

Linux Build:  
mkdir build  
cd build  
cmake -DCMAKE_CXX_COMPILER=clang++  -DCMAKE_BUILD_TYPE=RelWithDebInfo ..  
cmake --build .

perf annotate --stdio | awk -f regdetect_v1.awk  
perf record -g -o perf.data -- ./regpressure  
perf script -i perf.data -F insn --xed > regpressure.txt  
perf annotate --stdio -M intel | awk -f regdetect_v1.awk > regpressure_report.txt  
