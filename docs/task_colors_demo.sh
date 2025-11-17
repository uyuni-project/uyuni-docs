#!/bin/bash
# Demo script showing Task's colorized output capabilities

cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════════╗
║                    TASK COLOR OUTPUT FEATURES                                  ║
╔════════════════════════════════════════════════════════════════════════════════╗

Task provides several color output modes out of the box:

1. PREFIXED OUTPUT (Recommended)
   Shows task names in color before each command output
   
   Taskfile.yml:
     output: prefixed
   
   Output looks like:
     task: [build:html] python3 scripts/build_html.py uyuni en
     Building HTML for Uyuni (en)...
     task: [build:pdf] python3 scripts/build_pdf.py uyuni en
     Generating PDF...
     ✓ Build complete!

2. GROUP OUTPUT
   Groups output by task, cleaner for parallel execution
   
   Taskfile.yml:
     output: group
   
   Output looks like:
     ┌─── build:html ───┐
     │ Building HTML... │
     │ ✓ Done           │
     └──────────────────┘

3. INTERLEAVED (Default)
   Shows all output as it happens
   Best for debugging

══════════════════════════════════════════════════════════════════════════════════

COLORED STATUS MESSAGES

Task automatically colorizes:
  ✓ Success messages (green)
  ✗ Error messages (red)
  ⚠ Warning messages (yellow)
  ℹ Info messages (blue)
  
You can use these in your scripts:

  Python:
    print("\033[32m✓\033[0m Success!")
    print("\033[31m✗\033[0m Error!")
    print("\033[33m⚠\033[0m Warning!")
    print("\033[34mℹ\033[0m Info")

  Bash:
    echo -e "\e[32m✓\e[0m Success!"
    echo -e "\e[31m✗\e[0m Error!"
    echo -e "\e[33m⚠\e[0m Warning!"
    echo -e "\e[34mℹ\e[0m Info"

══════════════════════════════════════════════════════════════════════════════════

PROGRESS INDICATORS

Task shows progress for each task:
  • Running tasks are highlighted
  • Completed tasks show checkmarks
  • Failed tasks show errors in red
  • Skipped tasks (from cache) show in dim text

Example with parallel execution:
  
  $ task build:all
  
  task: [configure] ✓ Configured for uyuni
  task: [html:en] Building HTML (English)...
  task: [html:ja] Building HTML (Japanese)...
  task: [html:ko] Building HTML (Korean)...
  task: [html:en] ✓ Complete (1.2s)
  task: [html:ja] ✓ Complete (1.5s)
  task: [html:ko] ✓ Complete (1.3s)
  task: [build:all] ✓ All builds complete!

══════════════════════════════════════════════════════════════════════════════════

ENHANCED WITH CUSTOM HELP

Your custom help script provides:
  • Section headers in cyan
  • Command names in bright cyan
  • Descriptions in white
  • Examples in yellow
  • Variables in yellow
  • Notes with emoji in blue

Combined approach:
  1. task help          → Beautiful custom menu (your design)
  2. task --list        → Standard task list (built-in)
  3. task --summary X   → Detailed task help (from Taskfile)
  4. task X             → Colorized execution (automatic)

╔════════════════════════════════════════════════════════════════════════════════╗
║                         COMPARISON TO MAKE                                     ║
╔════════════════════════════════════════════════════════════════════════════════╗

Make:
  • Custom colors via printf/echo -e (manual)
  • ~50 lines of color code to maintain
  • Colors only in help text
  • No colored output during execution

Task:
  • Built-in colored output (automatic)
  • No color code to maintain
  • Colors in help AND execution
  • Custom help script if you want more

BEST OF BOTH:
  You get Make-style beautiful help menu + Task's automatic colored execution!

EOF
