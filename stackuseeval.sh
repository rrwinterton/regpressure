#
#export path to current directory
#export PATH=$(pwd):$PATH
#
#compile the test program
#used to build on linux
#cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-g -fno-omit-frame-pointer" -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
#cmake --build .
#run to test
#./regpressure
#run perf to collect data
#perf record -g -o perf.data -- ./regpressure
#perf script -i perf.data -F insn --xed > regpressure.txt
#perf annotate --stdio -M intel | awk -f regdetect_v1.awk > regpressure_report.txt
#todo:
#rework todo rrw: awk -f build/regpressure.awk regpressure_report.txt > final_report.txt