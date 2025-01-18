#!/bin/bash

# Function to calculate CPU usage
calculate_cpu_usage() {
  local cpu_line=("$@")
  local idle_time=${cpu_line[4]}
  local total_time=0

  for value in "${cpu_line[@]:1}"; do
    total_time=$((total_time + value))
  done

  echo "$idle_time $total_time"
}

# Read initial CPU stats
read -r -a cpu_line < <(grep '^cpu ' /proc/stat)
initial_cpu=($(calculate_cpu_usage "${cpu_line[@]}"))

initial_cores=()
while read -r -a core_line; do
  initial_cores+=("$(calculate_cpu_usage "${core_line[@]}")")
done < <(grep '^cpu[0-9]' /proc/stat)

# Wait for a second to get the next reading
sleep 1

# Read CPU stats again
read -r -a cpu_line < <(grep '^cpu ' /proc/stat)
final_cpu=($(calculate_cpu_usage "${cpu_line[@]}"))

final_cores=()
while read -r -a core_line; do
  final_cores+=("$(calculate_cpu_usage "${core_line[@]}")")
done < <(grep '^cpu[0-9]' /proc/stat)

# Calculate overall CPU usage
idle_diff=$((final_cpu[0] - initial_cpu[0]))
total_diff=$((final_cpu[1] - initial_cpu[1]))

if [ "$total_diff" -ne 0 ]; then
  overall_usage=$((100 * (total_diff - idle_diff) / total_diff))
else
  overall_usage=0
fi

tooltip_text="CPU Usage: $overall_usage%"

for i in "${!initial_cores[@]}"; do
  initial_core=(${initial_cores[$i]})
  final_core=(${final_cores[$i]})
  idle_diff=$((final_core[0] - initial_core[0]))
  total_diff=$((final_core[1] - initial_core[1]))

  if [ "$total_diff" -ne 0 ]; then
    core_usage=$((100 * (total_diff - idle_diff) / total_diff))
  else
    core_usage=0
  fi

  tooltip_text="${tooltip_text}\rCore $((i+1)): ${core_usage}%"
done

echo "{\"tooltip\":\"$tooltip_text\", \"percentage\": $overall_usage}"