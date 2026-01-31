#!/usr/bin/awk -f

BEGIN {
    # --- CONFIGURATION ---
    DEBUG = 0  # Set to 1 to see debug output
    THRESHOLD = 0.5 

    if (!DEBUG) {
        printf "%-40s | %-15s | %-15s\n", "Function Name", "Spill Cost %", "Est. Pressure"
        printf "%s\n", "--------------------------------------------------------------------------------"
    } else {
        print ">>> DEBUG MODE ENABLED <<<"
    }
    
    in_function = 0
    current_func = "unknown"
    func_spill_cost = 0.0
}

# ------------------------------------------------------------------------------
# BLOCK 1: Function Header Detection (Priority Method)
# ------------------------------------------------------------------------------
# We look for the pattern <Function_Name>: at the end of the line.
# This handles lines like: ": 5    0003dd85d0 <v8::Context::GetNumberOfEmbedderDataFields()@@Base>:"
($0 ~ /<[^>]+>:$/) {
    
    # 1. Find the text inside the angle brackets
    match($0, /<[^>]+>/)
    
    # 2. Extract the name (excluding the < and >)
    # RSTART+1 skips the '<'
    # RLENGTH-2 subtracts the length of '<' and '>'
    name = substr($0, RSTART+1, RLENGTH-2)

    # 3. Call helper to set the new function
    set_new_function(name)
    next
}

# ------------------------------------------------------------------------------
# BLOCK 2: Function Header Detection (Fallback Method)
# ------------------------------------------------------------------------------
# Catches simple headers like "func_name:" that don't have brackets.
# CRITICAL EXCLUSIONS:
# - !/^[[:space:]]*:/     -> Ignore source lines starting with colon (": 5")
# - !/^[[:space:]]*[0-9]/ -> Ignore assembly lines starting with numbers
!/<[^>]+>:$/ && !/^[[:space:]]*:/ && !/^[[:space:]]*[0-9]/ && !/^-/ && !/^Percent/ && !/Source code/ && ($0 ~ /:$/) {
    
    full_line = $0
    sub(/^[[:space:]]+/, "", full_line)
    
    # Split by double space to clean up standard perf output
    split(full_line, parts, "  ") 
    potential_name = parts[1]
    sub(/:$/, "", potential_name)

    # Safety Check: If name is empty, numeric, or starts with colon, skip it
    if (length(potential_name) == 0 || potential_name ~ /^[0-9]/ || potential_name ~ /^:/) next

    set_new_function(potential_name)
    next
}

# ------------------------------------------------------------------------------
# BLOCK 3: Assembly Line Processing
# ------------------------------------------------------------------------------
in_function {
    gsub(":", "", $1) # Remove colons from percentages
    
    # Must start with a number (overhead)
    if ($1 !~ /^[0-9.]+$/) next

    overhead = $1 + 0.0
    if (overhead == 0) next

    # DETECT REGISTER PRESSURE
    is_spill = 0
    if ($0 ~ /mov|MOV/) {
        # Check for stack access using Frame Pointer (rbp) or Stack Pointer (rsp)
        if ($0 ~ /%rsp|%rbp|\[rsp|\[rbp/) {
            is_spill = 1
        }
    }

    if (is_spill) {
        func_spill_cost += overhead
        if (DEBUG) print "DEBUG:   [SPILL] (" overhead "%) " $0
    }
}

END {
    if (in_function) report_function()
}

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
function set_new_function(name) {
    # If we were processing a previous function, report it first
    if (in_function) report_function()

    current_func = name
    if (DEBUG) print "DEBUG: [HEADER] Found function: " current_func

    func_spill_cost = 0.0
    in_function = 1
}

function report_function() {
    if (DEBUG) { 
        print "DEBUG: End of " current_func " (Total Spill: " func_spill_cost "%)"
        print "---"
        return
    }

    if (func_spill_cost > THRESHOLD) {
        pressure_desc = "Low"
        if (func_spill_cost > 5.0) pressure_desc = "Medium"
        if (func_spill_cost > 15.0) pressure_desc = "HIGH"
        
        printf "%-40s | %6.2f %%        | %s\n", substr(current_func, 1, 40), func_spill_cost, pressure_desc
    }
}