# Stop irqbalanced and remove CPU from IRQ affinity masks
# systemctl stop irqbalance.service
for i in /proc/irq/*/smp_affinity; do
    bits=$(cat $i | sed -e 's/,//')
    not_bits=$(echo $((((16#$bits) & ~(1<<47)))) | \
		           xargs printf %0.2x'\n' | \
		           sed ':a;s/\B[0-9a-f]\{8\}\>/,&/;ta')
    echo $not_bits > $i
done

export tracing_dir="/sys/kernel/debug/tracing"

# Remove -rt task runtime limit
echo -1 > /proc/sys/kernel/sched_rt_runtime_us

# increase buffer size to 100MB to avoid dropped events
echo 100000 > ${tracing_dir}/per_cpu/cpu${cpu}/buffer_size_kb

# Set tracing cpumask to trace just CPU 47
echo 0100,00000000 > ${tracing_dir}/tracing_cpumask

echo function > ${tracing_dir}/current_tracer

echo 1 > ${tracing_dir}/tracing_on
#timeout 30 cset shield --exec -- chrt -f 99 bash -c 'while :; do :; done'
#timeout 30 cset shield --exec -- chrt -f 99 bash -c 'while :; do :; done'
echo 0 > ${tracing_dir}/tracing_on

cat ${tracing_dir}/per_cpu/cpu${cpu}/trace > trace.txt
# clear trace buffer
echo > ${tracing_dir}/trace
