#!/usr/bin/env python3
"""
HTML Build Module
Builds HTML documentation using Antora
"""

import subprocess
import sys
from pathlib import Path
from typing import Optional
import shutil

from build_config import get_config, BuildConfig


class HTMLBuilder:
    """Builds HTML documentation using Antora"""
    
    def __init__(self, config: Optional[BuildConfig] = None):
        self.config = config or get_config()
        self.root_dir = Path.cwd()
    
    def check_antora(self) -> bool:
        """Check if Antora is installed"""
        result = subprocess.run(['which', 'antora'], capture_output=True)
        return result.returncode == 0
    
    def prepare_translations(self, langcode: str):
        """Prepare translation files for a language"""
        trans_dir = self.config.get_translations_dir(langcode)
        if not trans_dir.exists():
            print(f"Warning: No translations directory found for {langcode}: {trans_dir}")
            return
        
        print(f"✓ Translation files ready: {trans_dir}")
    
    def build(self, product: str = 'uyuni', lang: str = 'en', clean: bool = False) -> int:
        """
        Build HTML documentation
        
        Args:
            product: Product to build (uyuni, mlm)
            lang: Language code (en, ja, ko, zh_CN)
            clean: Clean build directory before building
            
        Returns:
            Exit code (0 = success)
        """
        try:
            # Validate inputs
            product_config = self.config.get_product(product)
            lang_config = self.config.get_language(lang)
            
            print(f"🌐 Building HTML: {product_config.productname} ({lang_config.name})")
            
            # Check if Antora is available
            if not self.check_antora():
                print("ERROR: Antora not found. Install with: npm install -g @antora/cli")
                return 1
            
            # Prepare translations
            self.prepare_translations(lang)
            
            # Determine site file
            site_file = f'site-{product}-{lang}.yml'
            if not Path(site_file).exists():
                # Fall back to generic site.yml
                site_file = 'site.yml'
                if not Path(site_file).exists():
                    print(f"ERROR: Site file not found: {site_file}")
                    return 1
            
            # Clean if requested
            build_dir = self.config.get_build_dir(lang)
            if clean and build_dir.exists():
                print(f"🧹 Cleaning {build_dir}")
                shutil.rmtree(build_dir)
            
            # Build with Antora
            print(f"📦 Running Antora: {site_file}")
            cmd = ['antora', '--fetch', site_file]
            
            result = subprocess.run(cmd, cwd=self.root_dir)
            
            if result.returncode == 0:
                print(f"✓ HTML build complete → {build_dir}")
                index_file = build_dir / 'index.html'
                if index_file.exists():
                    print(f"  Open: file://{index_file.absolute()}")
            else:
                print(f"✗ Build failed with exit code {result.returncode}")
            
            return result.returncode
            
        except ValueError as e:
            print(f"ERROR: {e}")
            return 1
        except Exception as e:
            print(f"ERROR: Unexpected error: {e}")
            import traceback
            traceback.print_exc()
            return 1


def main():
    """CLI entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Build HTML documentation')
    parser.add_argument('--product', '-p', default='uyuni',
                       help='Product to build (uyuni, mlm)')
    parser.add_argument('--lang', '-l', default='en',
                       help='Language code (en, ja, ko, zh_CN)')
    parser.add_argument('--clean', '-c', action='store_true',
                       help='Clean build directory before building')
    
    args = parser.parse_args()
    
    builder = HTMLBuilder()
    exit_code = builder.build(
        product=args.product,
        lang=args.lang,
        clean=args.clean
    )
    
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
