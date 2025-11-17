# Modular Taskfile Structure

## Overview

Yes, Task **strongly supports** modularization through the `includes` feature. This is considered **best practice** for large projects.

## Structure

```
uyuni-docs/
├── Taskfile.yml                      # Main entry point
├── tasks/                            # Modular task files
│   ├── Taskfile.config.yml          # Configuration tasks
│   ├── Taskfile.html.yml            # HTML build tasks
│   ├── Taskfile.pdf.yml             # PDF build tasks
│   ├── Taskfile.translate.yml       # Translation tasks
│   ├── Taskfile.quality.yml         # Validation & quality
│   ├── Taskfile.package.yml         # Packaging tasks
│   ├── Taskfile.clean.yml           # Cleanup tasks
│   └── Taskfile.dev.yml             # Development helpers
└── scripts/                          # Python scripts called by tasks
    ├── setup.py
    ├── build_html.py
    ├── build_pdf.py
    └── ...
```

## Benefits of Modularization

### 1. **Organization**
- Each module focuses on one aspect (HTML, PDF, translations, etc.)
- Easy to find and modify specific functionality
- Clear separation of concerns

### 2. **Maintainability**
- Smaller files are easier to understand
- Changes to one module don't affect others
- Multiple people can work on different modules simultaneously

### 3. **Reusability**
- Modules can be included in different Taskfiles
- Share common modules across projects
- Version control is cleaner (smaller diffs)

### 4. **Namespacing**
- Tasks are automatically namespaced by their include name
- Example: `task html:build`, `task pdf:all`, `task clean:build`
- No naming conflicts between modules

### 5. **Scalability**
- Easy to add new modules as project grows
- Can disable modules by commenting out includes
- Conditional includes based on environment

## How It Works

### Main Taskfile (Taskfile.yml)
```yaml
version: '3'

# Global variables available to all modules
vars:
  PRODUCT: '{{.PRODUCT | default "uyuni"}}'
  LANG: '{{.LANG | default "en"}}'

# Include modular taskfiles
includes:
  html:
    taskfile: ./tasks/Taskfile.html.yml
    dir: .                    # Run from project root
    
  pdf:
    taskfile: ./tasks/Taskfile.pdf.yml
    dir: .

# Top-level orchestration tasks
tasks:
  build:
    cmds:
      - task: html:build      # Calls html module
      - task: pdf:all         # Calls pdf module
```

### Module Taskfile (tasks/Taskfile.html.yml)
```yaml
version: '3'

tasks:
  build:
    desc: Build HTML documentation
    cmds:
      - python3 scripts/build_html.py {{.PRODUCT}} {{.LANG}}
      # Variables from main Taskfile are available here!
```

## Usage Examples

### Running Tasks with Namespaces
```bash
# From main Taskfile
task build                    # Orchestration task

# From modules (namespaced)
task html:build              # HTML module
task html:multi              # HTML module, specific task
task pdf:all                 # PDF module
task pdf:section SECTION=admin  # PDF module with variable
task clean:all               # Clean module
task config:uyuni            # Config module
task quality:validate        # Quality module
```

### Listing Tasks
```bash
task --list                  # All tasks (grouped by namespace)
task --list html             # Only HTML module tasks
task --list-all              # Include internal tasks too
```

## Advanced Features

### 1. Optional Includes
```yaml
includes:
  experimental:
    taskfile: ./tasks/Taskfile.experimental.yml
    optional: true           # Won't fail if file doesn't exist
```

### 2. Aliases (Flatten Namespaces)
```yaml
includes:
  html:
    taskfile: ./tasks/Taskfile.html.yml
    aliases: [h]             # Can use 'task h:build'
```

### 3. Internal Tasks
```yaml
# In module file
tasks:
  lang:
    internal: true           # Won't show in 'task --list'
    cmds:
      - python3 scripts/build.py {{.LANG}}
```

### 4. Pass Variables to Specific Modules
```yaml
includes:
  html:
    taskfile: ./tasks/Taskfile.html.yml
    vars:
      CUSTOM_VAR: value      # Only available in html module
```

## Comparison: Monolithic vs Modular

### Monolithic (Current Taskfile.yml)
```
✗ 450+ lines in one file
✗ Hard to navigate
✗ Complex to modify
✗ Merge conflicts likely
✗ No clear organization
```

### Modular (Proposed Structure)
```
✓ ~100 lines per module
✓ Easy to navigate (by module name)
✓ Simple to modify (change one file)
✓ Fewer merge conflicts
✓ Clear, logical organization
✓ Self-documenting structure
```

## Migration from Monolithic

### Step 1: Identify Logical Groupings
Look at your current Taskfile and group related tasks:
- Configuration tasks → `Taskfile.config.yml`
- Build tasks → `Taskfile.html.yml`, `Taskfile.pdf.yml`
- Quality tasks → `Taskfile.quality.yml`
- Etc.

### Step 2: Extract to Modules
Move tasks to separate files, keeping `version: '3'` and `tasks:` structure.

### Step 3: Add Includes
In main Taskfile:
```yaml
includes:
  config: ./tasks/Taskfile.config.yml
  html: ./tasks/Taskfile.html.yml
  # etc.
```

### Step 4: Update Task Calls
```yaml
# Before (monolithic)
cmds:
  - task: configure-uyuni

# After (modular)
cmds:
  - task: config:uyuni
```

### Step 5: Test
```bash
task --list                  # Verify all tasks appear
task html:build              # Test namespaced calls
```

## Real-World Example: Your Project

### Current (Monolithic)
```
Taskfile.yml (450 lines)
├── Configuration (2 tasks)
├── HTML builds (3 tasks)
├── PDF builds (2 tasks)
├── Complete builds (2 tasks)
├── Translations (1 task)
├── Validation (3 tasks)
├── Packaging (2 tasks)
├── Cleanup (3 tasks)
├── Development (1 task)
└── Shortcuts (3 tasks)
```

### Proposed (Modular)
```
Taskfile.yml (100 lines)                    # Main + orchestration
tasks/
├── Taskfile.config.yml (40 lines)         # 2 config tasks
├── Taskfile.html.yml (60 lines)           # 3 HTML tasks
├── Taskfile.pdf.yml (70 lines)            # 2 PDF tasks
├── Taskfile.translate.yml (50 lines)      # 3 translation tasks
├── Taskfile.quality.yml (60 lines)        # 4 quality tasks
├── Taskfile.package.yml (55 lines)        # 3 packaging tasks
├── Taskfile.clean.yml (50 lines)          # 4 cleanup tasks
└── Taskfile.dev.yml (45 lines)            # 3 dev tasks
```

## Recommendations

### ✅ **DO** Modularize If:
- You have 10+ tasks
- Tasks group naturally into categories
- Multiple people work on the build system
- You want clear organization
- Your project will grow over time

### ❌ **DON'T** Modularize If:
- You have < 10 tasks
- All tasks are tightly coupled
- It's a simple single-purpose tool
- You prefer everything in one file

## Your Project: **DEFINITELY MODULARIZE**

With 20+ tasks across multiple domains (config, HTML, PDF, translations, quality, packaging, cleanup, dev), modularization is **absolutely** the right choice.

## Next Steps

1. **Review** the modular structure I created
2. **Test** with: `mv Taskfile.modular.yml Taskfile.yml`
3. **Verify** tasks work: `task --list`
4. **Iterate** - adjust module boundaries as needed
5. **Enjoy** the cleaner, more maintainable structure!

## Summary

**Modularization with Task is:**
- ✅ A built-in feature (not a hack)
- ✅ Best practice for large projects
- ✅ Simple to implement
- ✅ Easy to maintain
- ✅ Recommended for your project

The lint errors you saw are just VS Code not recognizing the YAML schema - the files are valid Task format.
