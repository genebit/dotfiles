#!/bin/bash
# wofi-calc: quick calculator using wofi + python3
# Usage: bind to a keybinding, type an expression, press Enter to copy result

expr=$(echo "" | wofi \
    --dmenu \
    --prompt "  Calc: " \
    --lines 0 \
    --width 500 \
    --height 68 \
    --cache-file /dev/null \
    --hide-scroll \
    --no-actions)

[[ -z "$expr" ]] && exit 0

# Evaluate safely via env variable (avoids shell injection)
result=$(CALC_EXPR="$expr" python3 -c "
import math, os
safe = {k: getattr(math, k) for k in dir(math) if not k.startswith('_')}
safe.update({'abs': abs, 'round': round, 'int': int, 'float': float, 'pow': pow})
try:
    r = eval(os.environ['CALC_EXPR'], {'__builtins__': {}}, safe)
    print(int(r) if isinstance(r, float) and r.is_integer() else r)
except Exception:
    print('Error: invalid expression')
" 2>/dev/null)

# Show result — pressing Enter copies it to clipboard
choice=$(printf '%s' "$result" | wofi \
    --dmenu \
    --prompt "  $expr = " \
    --lines 1 \
    --width 500 \
    --height 68 \
    --cache-file /dev/null \
    --hide-scroll \
    --no-actions)

[[ -n "$choice" ]] && printf '%s' "$choice" | wl-copy
