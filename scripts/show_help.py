#!/usr/bin/env python3
"""
Custom colored help menu for Uyuni documentation build system
Provides a nicely formatted alternative to 'task --list'
"""

import sys
from pathlib import Path

# ANSI color codes
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    
    # Foreground colors
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    
    # Bright foreground colors
    BRIGHT_BLACK = '\033[90m'
    BRIGHT_RED = '\033[91m'
    BRIGHT_GREEN = '\033[92m'
    BRIGHT_YELLOW = '\033[93m'
    BRIGHT_BLUE = '\033[94m'
    BRIGHT_MAGENTA = '\033[95m'
    BRIGHT_CYAN = '\033[96m'
    BRIGHT_WHITE = '\033[97m'

def print_header(title):
    """Print a colored section header"""
    print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.WHITE}  {title}{Colors.RESET}")
    print(f"{Colors.CYAN}{'='*60}{Colors.RESET}\n")

def print_section(title, subtitle=""):
    """Print a section title"""
    print(f"{Colors.GREEN}{title}:{Colors.RESET}", end="")
    if subtitle:
        print(f" {Colors.YELLOW}{subtitle}{Colors.RESET}")
    else:
        print()

def print_command(cmd, desc, indent=2):
    """Print a command with description"""
    spaces = " " * indent
    print(f"{spaces}{Colors.CYAN}{cmd:<35}{Colors.RESET} {desc}")

def print_example(cmd, desc=""):
    """Print an example command"""
    if desc:
        print(f"  {Colors.BRIGHT_BLACK}# {desc}{Colors.RESET}")
    print(f"  {Colors.BRIGHT_YELLOW}task {cmd}{Colors.RESET}")

def print_note(text):
    """Print a note or tip"""
    print(f"  {Colors.BRIGHT_BLUE}💡 {text}{Colors.RESET}")

def main():
    print_header("🚀 Uyuni Documentation Build System")
    
    # Configuration Section
    print_section("CONFIGURATION", "(Run this first to configure your product)")
    print_command("configure:uyuni", "Configure for Uyuni builds")
    print_command("configure:mlm", "Configure for SUSE Multi-Linux Manager builds")
    
    # Quick Start Examples
    print_section("\nQUICK START EXAMPLES")
    print_example("html", "Build Uyuni HTML (English, fast)")
    print_example("html LANG=ja", "Build Japanese HTML")
    print_example("build", "Complete build (HTML + all PDFs)")
    print_example("build:all", "Build everything for ALL languages")
    print_example("clean", "Clean English build artifacts")
    print()
    
    # HTML Documentation Builds
    print_section("HTML DOCUMENTATION BUILDS", "(Fast, for development)")
    print_command("html", "Build HTML only (fastest option)")
    print_command("html LANG=<lang>", "Build HTML for specific language")
    print_command("html LANGS=\"en ja ko\"", "Build HTML for multiple languages")
    print_command("html PRODUCT=mlm", "Build SUSE MLM instead of Uyuni")
    print_note("Use 'html' targets for quick iteration during development")
    
    # PDF Documentation Builds  
    print_section("\nPDF DOCUMENTATION BUILDS")
    print_command("pdf:all", "Build ALL PDF guides for a language")
    print_command("pdf:section SECTION=<name>", "Build single PDF guide")
    print()
    print(f"  {Colors.BRIGHT_BLACK}Available sections:{Colors.RESET}")
    sections = [
        "installation-and-upgrade", "client-configuration", "administration",
        "reference", "retail", "common-workflows", "specialized-guides", "legal"
    ]
    for section in sections:
        print(f"    {Colors.DIM}• {section}{Colors.RESET}")
    
    # Complete Builds
    print_section("\nCOMPLETE BUILD + PACKAGING")
    print_command("build", "Complete build for one language (HTML + PDFs)")
    print_command("build:all", "Complete build for ALL languages")
    print_command("package", "Create OBS packages for distribution")
    print_command("package:all", "Create OBS packages for ALL languages")
    print_note("Use 'build' targets for production-ready output")
    
    # Translations
    print_section("\nTRANSLATIONS")
    print_command("translate", "Sync all translations with Weblate/po4a")
    print_command("translate LANG=<lang>", "Sync specific language only")
    print_note("Run after pulling updates from Weblate")
    
    # Validation & Quality
    print_section("\nVALIDATION & QUALITY")
    print_command("validate", "Validate documentation structure and links")
    print_command("checkstyle", "Check AsciiDoc style compliance")
    print_command("checkstyle:fix", "Auto-fix AsciiDoc style issues")
    
    # Maintenance
    print_section("\nMAINTENANCE & CLEANUP")
    print_command("clean", "Remove build artifacts for a language")
    print_command("clean:all", "Remove ALL build artifacts")
    print_command("clean:branding", "Remove branding files")
    
    # Development Helpers
    print_section("\nDEVELOPMENT HELPERS")
    print_command("dev", "Start development server with live reload")
    print_command("quick", "Quick HTML-only build (alias for 'html')")
    print_command("full", "Full build (alias for 'build')")
    print_command("list", "List all available tasks")
    
    # Variables Section
    print_section("\nAVAILABLE VARIABLES")
    print(f"  {Colors.CYAN}PRODUCT{Colors.RESET}  = {Colors.YELLOW}uyuni{Colors.RESET} | {Colors.YELLOW}mlm{Colors.RESET}  {Colors.DIM}(default: uyuni){Colors.RESET}")
    print(f"  {Colors.CYAN}LANG{Colors.RESET}     = {Colors.YELLOW}en{Colors.RESET} | {Colors.YELLOW}ja{Colors.RESET} | {Colors.YELLOW}ko{Colors.RESET} | {Colors.YELLOW}zh_CN{Colors.RESET}  {Colors.DIM}(default: en){Colors.RESET}")
    print(f"  {Colors.CYAN}LANGS{Colors.RESET}    = {Colors.DIM}Space-separated list for multiple languages{Colors.RESET}")
    print(f"  {Colors.CYAN}SECTION{Colors.RESET}  = {Colors.DIM}One of the available sections (see PDF section above){Colors.RESET}")
    print(f"  {Colors.CYAN}PORT{Colors.RESET}     = {Colors.DIM}Port for dev server (default: 8000){Colors.RESET}")
    
    # Usage Tips
    print_section("\nUSAGE TIPS")
    print_command("task --list", "Show all tasks (standard format)")
    print_command("task --summary <name>", "Show detailed help for a task")
    print_command("task --dry <command>", "Preview what would run")
    print_command("task <name> --help", "Show task-specific help")
    print()
    print_note("Variables can be set like: task html PRODUCT=mlm LANG=ja")
    print_note("Enable tab completion: https://taskfile.dev/installation/#setup-completions")
    
    # Footer
    print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
    print(f"{Colors.BRIGHT_BLACK}For more information: task --list or task --summary <task-name>{Colors.RESET}")
    print(f"{Colors.CYAN}{'='*60}{Colors.RESET}\n")

if __name__ == "__main__":
    main()
