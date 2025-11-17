#!/usr/bin/env python3
"""
Setup/Configure Script
Replaces the old ./configure script
Generates necessary configuration files for builds
"""

import sys
from pathlib import Path
from typing import Optional
from jinja2 import Environment, FileSystemLoader

from build_config import get_config, BuildConfig


class SetupManager:
    """Manages project setup and configuration"""
    
    def __init__(self, config: Optional[BuildConfig] = None):
        self.config = config or get_config()
        self.root_dir = Path.cwd()
        self.env = Environment(
            loader=FileSystemLoader('./'),
            trim_blocks=True,
            lstrip_blocks=True
        )
    
    def generate_site_yml(self, product: str, lang: str) -> Path:
        """
        Generate Antora site.yml file for a specific product and language
        
        Args:
            product: Product ID (uyuni, mlm)
            lang: Language code
            
        Returns:
            Path to generated site.yml
        """
        product_config = self.config.get_product(product)
        lang_config = self.config.get_language(lang)
        
        output_file = Path(f'site-{product}-{lang}.yml')
        
        # Check if template exists
        template_file = Path('site.yml.j2')
        if not template_file.exists():
            print(f"Warning: Template not found: {template_file}")
            print("Using site.yml directly")
            return Path('site.yml')
        
        # Load and render template
        template = self.env.get_template('site.yml.j2')
        
        # Prepare context
        context = {
            'product': product,
            'langcode': lang,
            'product_config': product_config,
            'lang_config': lang_config,
            **self.config.data
        }
        
        # Render and write
        rendered = template.render(context)
        output_file.write_text(rendered)
        
        print(f"✓ Generated: {output_file}")
        return output_file
    
    def generate_antora_yml(self, product: str, lang: str) -> Path:
        """
        Generate antora.yml file for a specific product and language
        
        Args:
            product: Product ID
            lang: Language code
            
        Returns:
            Path to generated antora.yml
        """
        product_config = self.config.get_product(product)
        lang_config = self.config.get_language(lang)
        
        output_file = Path(f'antora-{product}-{lang}.yml')
        
        # Check if template exists
        template_file = Path('antora.yml.j2')
        if not template_file.exists():
            print(f"Warning: Template not found: {template_file}")
            return Path('antora.yml')
        
        # Load and render template
        template = self.env.get_template('antora.yml.j2')
        
        # Prepare context
        context = {
            'product': product,
            'langcode': lang,
            'product_config': product_config,
            'lang_config': lang_config,
            **self.config.data
        }
        
        # Render and write
        rendered = template.render(context)
        output_file.write_text(rendered)
        
        print(f"✓ Generated: {output_file}")
        return output_file
    
    def configure(self, product: str) -> int:
        """
        Configure the project for a specific product
        Generates necessary configuration files
        
        Args:
            product: Product ID (uyuni, mlm)
            
        Returns:
            Exit code (0 = success)
        """
        try:
            # Validate product
            product_config = self.config.get_product(product)
            
            print(f"🔧 Configuring for: {product_config.productname}")
            
            # Generate configuration for all languages
            for lang in self.config.list_languages():
                print(f"\n  Configuring {lang}...")
                self.generate_site_yml(product, lang)
                # Optionally generate antora.yml if needed
                # self.generate_antora_yml(product, lang)
            
            print(f"\n✓ Configuration complete for {product}")
            print(f"\nNext steps:")
            print(f"  - Build HTML: task html PRODUCT={product}")
            print(f"  - Build PDFs: task pdf PRODUCT={product}")
            
            return 0
            
        except ValueError as e:
            print(f"ERROR: {e}")
            return 1
        except Exception as e:
            print(f"ERROR: Unexpected error: {e}")
            import traceback
            traceback.print_exc()
            return 1
    
    def verify_dependencies(self) -> bool:
        """
        Verify that required tools are installed
        
        Returns:
            True if all dependencies are available
        """
        import subprocess
        
        dependencies = {
            'antora': 'npm install -g @antora/cli @antora/site-generator-default',
            'asciidoctor': 'gem install asciidoctor',
            'asciidoctor-pdf': 'gem install asciidoctor-pdf',
            'po4a': 'zypper install po4a (or apt/yum equivalent)',
        }
        
        print("🔍 Checking dependencies...")
        missing = []
        
        for tool, install_cmd in dependencies.items():
            result = subprocess.run(
                ['which', tool],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                # Get version if possible
                version_result = subprocess.run(
                    [tool, '--version'],
                    capture_output=True,
                    text=True
                )
                version = version_result.stdout.strip().split('\n')[0] if version_result.returncode == 0 else 'unknown'
                print(f"  ✓ {tool}: {version}")
            else:
                print(f"  ✗ {tool}: not found")
                print(f"    Install with: {install_cmd}")
                missing.append(tool)
        
        if missing:
            print(f"\n⚠️  Missing {len(missing)} dependencies: {', '.join(missing)}")
            print("\nTip: Use the container build to avoid installing dependencies:")
            print("  task container:build")
            print("  task container:html")
            return False
        else:
            print("\n✓ All dependencies found")
            return True
    
    def show_info(self):
        """Display configuration information"""
        print("📋 Build System Configuration")
        print("=" * 60)
        
        print("\nAvailable Products:")
        for product_id in self.config.list_products():
            product = self.config.get_product(product_id)
            print(f"  - {product_id:12} : {product.productname} {product.productnumber}")
            print(f"    {'':12}   Sections: {', '.join(product.sections)}")
        
        print("\nAvailable Languages:")
        for langcode in self.config.list_languages():
            lang = self.config.get_language(langcode)
            cjk_flag = " [CJK]" if lang.is_cjk else ""
            print(f"  - {langcode:12} : {lang.name}{cjk_flag}")
        
        print("\nBuild Directories:")
        for lang in self.config.list_languages():
            build_dir = self.config.get_build_dir(lang)
            pdf_dir = self.config.get_pdf_dir(lang)
            print(f"  - {lang:12} : {build_dir} (HTML), {pdf_dir} (PDF)")
        
        print("\nUsage:")
        print("  ./scripts/setup.py configure <product>")
        print("  ./scripts/setup.py info")
        print("  ./scripts/setup.py verify")


def main():
    """CLI entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Setup and configure Uyuni documentation builds',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s configure uyuni      # Configure for Uyuni
  %(prog)s configure mlm        # Configure for SUSE MLM
  %(prog)s info                 # Show configuration
  %(prog)s verify               # Verify dependencies
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # Configure command
    configure_parser = subparsers.add_parser('configure', help='Configure for a product')
    configure_parser.add_argument('product', help='Product to configure (uyuni, mlm)')
    
    # Info command
    subparsers.add_parser('info', help='Show configuration information')
    
    # Verify command
    subparsers.add_parser('verify', help='Verify dependencies')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(0)
    
    manager = SetupManager()
    
    if args.command == 'configure':
        exit_code = manager.configure(args.product)
    elif args.command == 'info':
        manager.show_info()
        exit_code = 0
    elif args.command == 'verify':
        all_ok = manager.verify_dependencies()
        exit_code = 0 if all_ok else 1
    else:
        parser.print_help()
        exit_code = 1
    
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
