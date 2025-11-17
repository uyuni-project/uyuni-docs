# VS Code YAML Schema Configuration for Taskfile

## What I Did

I configured VS Code to recognize Task's YAML schema in two ways:

### 1. Workspace Settings (.vscode/settings.json)
```json
{
  "yaml.schemas": {
    "https://taskfile.dev/schema.json": [
      "Taskfile.yml",
      "Taskfile.*.yml",
      "tasks/Taskfile.*.yml"
    ]
  }
}
```

This tells the YAML extension to use Task's official schema for:
- Main `Taskfile.yml`
- Any `Taskfile.*.yml` files (like `Taskfile.modular.yml`)
- Any Taskfiles in the `tasks/` directory

### 2. Inline Schema Comments (in each Taskfile)
```yaml
# yaml-language-server: $schema=https://taskfile.dev/schema.json

version: '3'
tasks:
  ...
```

This is a per-file directive that tells the YAML language server to use Task's schema.

## Benefits

✅ **Autocomplete** - VS Code suggests Task properties as you type
✅ **Validation** - Errors for invalid Task syntax
✅ **Documentation** - Hover over properties to see docs
✅ **IntelliSense** - Smart suggestions based on context
✅ **Error highlighting** - Red squiggles for problems

## What You Need

### Required VS Code Extension
Install the **YAML extension** by Red Hat:
```
Name: YAML
Id: redhat.vscode-yaml
```

Install it:
1. Open VS Code Extensions (Ctrl+Shift+X)
2. Search for "YAML"
3. Install "YAML" by Red Hat

Or via command line:
```bash
code --install-extension redhat.vscode-yaml
```

## Verify It's Working

1. Open any `Taskfile.yml` or `tasks/Taskfile.*.yml`
2. Start typing a task property - you should see autocomplete
3. Hover over properties like `version`, `tasks`, `cmds` - you should see documentation
4. Invalid properties should show red squiggles

## Alternative Methods

### Method 1: Inline Comment (Current - Best for Git)
```yaml
# yaml-language-server: $schema=https://taskfile.dev/schema.json
version: '3'
```

**Pros:**
- Works in any editor that supports YAML language server
- Committed to git, works for everyone
- No workspace configuration needed

**Cons:**
- Must add to each file

### Method 2: Workspace Settings (Current)
```json
{
  "yaml.schemas": {
    "https://taskfile.dev/schema.json": ["Taskfile*.yml", "tasks/*.yml"]
  }
}
```

**Pros:**
- Applies to all matching files automatically
- Cleaner Taskfiles

**Cons:**
- Only works in VS Code
- Requires extension installed

### Method 3: User Settings (Global)
Add to your user `settings.json`:
```json
{
  "yaml.schemas": {
    "https://taskfile.dev/schema.json": ["**/Taskfile*.yml"]
  }
}
```

**Pros:**
- Works in all projects
- Set once, forget it

**Cons:**
- Might conflict with other YAML files
- Only applies to your machine

### Method 4: YAML Extension Settings
In `.vscode/extensions.json`:
```json
{
  "recommendations": [
    "redhat.vscode-yaml"
  ]
}
```

**Pros:**
- Recommends extension to team members
- No manual installation needed

**Cons:**
- Still need schema configuration

## Recommended Setup (What I Implemented)

**Both Method 1 + Method 2** for maximum compatibility:

1. ✅ Inline comments in each Taskfile (works anywhere)
2. ✅ Workspace settings (cleaner in VS Code)
3. ✅ Extensions recommendation (helps team members)

## Troubleshooting

### Schema not loading?
1. Reload VS Code window: `Ctrl+Shift+P` → "Reload Window"
2. Check YAML extension is installed: `Ctrl+Shift+X` → search "YAML"
3. Verify schema URL is accessible: https://taskfile.dev/schema.json

### Still showing errors?
Some errors might be legitimate - Task's schema is strict. Check:
- Property names (case-sensitive)
- Required properties (`version`, `tasks`)
- Valid property combinations

### Autocomplete not working?
1. Make sure cursor is in the right context
2. Try `Ctrl+Space` to manually trigger
3. Check file is recognized as YAML (bottom right of VS Code)

## What's Now Configured

All these files now have schema support:
- ✅ `Taskfile.yml`
- ✅ `Taskfile.modular.yml`
- ✅ `tasks/Taskfile.config.yml`
- ✅ `tasks/Taskfile.html.yml`
- ✅ `tasks/Taskfile.pdf.yml`
- ✅ `tasks/Taskfile.translate.yml`
- ✅ `tasks/Taskfile.quality.yml`
- ✅ `tasks/Taskfile.package.yml`
- ✅ `tasks/Taskfile.clean.yml`
- ✅ `tasks/Taskfile.dev.yml`

## Next Steps

1. **Reload VS Code** - For settings to take effect
2. **Open a Taskfile** - You should see validation/autocomplete
3. **Try typing** - Start a new task and see suggestions
4. **Hover on properties** - See Task documentation inline

Enjoy your enhanced Taskfile editing experience! 🎉
