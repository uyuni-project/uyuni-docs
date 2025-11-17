#!/usr/bin/env python3
"""
PDF Build Module
Builds PDF documentation using Asciidoctor-PDF
"""

import subprocess
import sys
from pathlib import Path
from typing import Optional, List
import shutil
import os
import re

from build_config import get_config, BuildConfig


class PDFBuilder:
    """Builds PDF documentation using Asciidoctor-PDF"""
    
    def __init__(self, config: Optional[BuildConfig] = None):
        self.config = config or get_config()
        self.root_dir = Path.cwd()
        self.branding_dir = Path('branding/pdf')
    
    def check_asciidoctor(self) -> bool:
        """Check if asciidoctor-pdf is installed"""
        try:
            result = subprocess.run(['asciidoctor-pdf', '--version'], 
                                  capture_output=True, text=True)
            return result.returncode == 0
        except FileNotFoundError:
            return False
    
    def get_theme_file(self, product: str) -> Path:
        """Get the PDF theme file for a product"""
        theme_file = self.branding_dir / 'themes' / f'{product}-theme.yml'
        if not theme_file.exists():
            # Fall back to default theme
            theme_file = self.branding_dir / 'themes' / 'default-theme.yml'
        return theme_file
    
    def get_fonts_dir(self) -> Path:
        """Get the fonts directory for PDF generation"""
        return self.branding_dir / 'fonts'
    
    def transform_nav_to_pdf(self, nav_file: Path, section: str, lang: str) -> Path:
        """
        Transform Antora nav file to PDF index file
        
        Converts:
          * xref:file.adoc[Title] → include::modules/SECTION/pages/file.adoc[leveloffset=+0]
          ** xref:file.adoc[Title] → include::modules/SECTION/pages/file.adoc[leveloffset=+1]
          ** Heading → == Heading
        
        Args:
            nav_file: Path to source nav file
            section: Section name (e.g., 'installation-and-upgrade')
            lang: Language code (e.g., 'en')
            
        Returns:
            Path to generated PDF index file
        """
        with open(nav_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Transformation rules (same order as Make sed commands)
        # Replace xref links with include directives, based on bullet depth
        replacements = [
            # 5 stars → leveloffset +4
            (r'\*{5}\s+xref:(.+?)\.adoc\[.*?\]', 
             rf'include::modules/{section}/pages/\1.adoc[leveloffset=+4]'),
            # 4 stars → leveloffset +3
            (r'\*{4}\s+xref:(.+?)\.adoc\[.*?\]', 
             rf'include::modules/{section}/pages/\1.adoc[leveloffset=+3]'),
            # 3 stars → leveloffset +2
            (r'\*{3}\s+xref:(.+?)\.adoc\[.*?\]', 
             rf'include::modules/{section}/pages/\1.adoc[leveloffset=+2]'),
            # 2 stars → leveloffset +1
            (r'\*{2}\s+xref:(.+?)\.adoc\[.*?\]', 
             rf'include::modules/{section}/pages/\1.adoc[leveloffset=+1]'),
            # 1 star → leveloffset +0
            (r'\*{1}\s+xref:(.+?)\.adoc\[.*?\]', 
             rf'include::modules/{section}/pages/\1.adoc[leveloffset=+0]'),
            # Plain bullets (no xref) → Section headings
            (r'\*{4}\s+(.+)', r'==== \1'),
            (r'\*{3}\s+(.+)', r'=== \1'),
            (r'\*{2}\s+(.+)', r'== \1'),
            (r'\*{1}\s+(.+)', r'= \1'),
        ]
        
        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
        
        # Output file: nav-SECTION-guide.pdf.LANG.adoc
        output_file = nav_file.parent / f"{nav_file.stem}.pdf.{lang}.adoc"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return output_file
    
    def build_section_pdf(
        self,
        product: str,
        lang: str,
        section: str,
        output_name: Optional[str] = None
    ) -> int:
        """
        Build PDF for a specific documentation section
        
        Args:
            product: Product ID (uyuni, mlm)
            lang: Language code
            section: Section name (e.g., 'installation-and-upgrade')
            output_name: Optional output filename (without .pdf extension)
            
        Returns:
            Exit code (0 = success)
        """
        try:
            # Get configurations
            product_config = self.config.get_product(product)
            lang_config = self.config.get_language(lang)
            
            print(f"📄 Building PDF: {section} - {product_config.productname} ({lang_config.name})")
            
            # Check asciidoctor-pdf
            if not self.check_asciidoctor():
                print("ERROR: asciidoctor-pdf not found. Install with: gem install asciidoctor-pdf")
                return 1
            
            # Setup paths
            trans_dir = self.config.get_translations_dir(lang)
            pdf_dir = self.config.get_pdf_dir(lang)
            pdf_dir.mkdir(parents=True, exist_ok=True)
            
            # Find and transform the nav file
            modules_dir = trans_dir / 'modules' / section
            nav_file = modules_dir / f'nav-{section}-guide.adoc'
            
            if not nav_file.exists():
                print(f"ERROR: Nav file not found: {nav_file}")
                return 1
            
            # Transform nav file to PDF index
            print(f"  Transforming: {nav_file.name} → PDF index")
            index_file = self.transform_nav_to_pdf(nav_file, section, lang)
            
            # Output filename
            if not output_name:
                # Use format like Make: suse_multi_linux_manager_installation-and-upgrade_guide.pdf
                output_name = f"{product_config.filename}_{section}_guide"
            output_pdf = pdf_dir / f"{output_name}.pdf"
            
            # Build asciidoctor command
            # Use extensions/xref-converter.rb like Make does
            cmd = [
                'asciidoctor-pdf',
                '-r', str(self.root_dir / 'extensions' / 'xref-converter.rb'),
                '-a', f'pdf-themesdir={self.branding_dir}/themes',
                '-a', f'pdf-theme={product}',
                '-a', f'pdf-fontsdir={self.branding_dir}/fonts',
                '-a', f'productname={product_config.productname}',
                '-a', f'{product_config.content_flag}=true',
                '-a', f'examplesdir=modules/{section}/examples',
                '-a', f'imagesdir=modules/{section}/assets/images',
                '-a', f'lang={lang}',
                '--base-dir', '.',
                '--out-file', str(output_pdf.absolute()),
            ]
            
            # Add CJK support if needed
            if lang_config.is_cjk:
                cmd.extend(['-a', 'scripts=cjk'])
            
            # Add the source file (relative to trans_dir)
            cmd.append(str(index_file.relative_to(trans_dir)))
            
            print(f"  Running: asciidoctor-pdf → {output_pdf.name}")
            
            # Set environment for locale
            env = os.environ.copy()
            env['LANG'] = lang_config.locale
            env['LC_ALL'] = lang_config.locale
            
            # Run from translations/LANG directory (like Make does)
            result = subprocess.run(cmd, cwd=trans_dir, env=env)
            
            if result.returncode == 0:
                print(f"✓ PDF created: {output_pdf}")
                if output_pdf.exists():
                    size_mb = output_pdf.stat().st_size / (1024 * 1024)
                    print(f"  Size: {size_mb:.2f} MB")
            else:
                print(f"✗ PDF build failed with exit code {result.returncode}")
            
            return result.returncode
            
        except ValueError as e:
            print(f"ERROR: {e}")
            return 1
        except Exception as e:
            print(f"ERROR: Unexpected error: {e}")
            import traceback
            traceback.print_exc()
            return 1
    
    def build_all_pdfs(
        self,
        product: str = 'uyuni',
        lang: str = 'en'
    ) -> int:
        """
        Build all PDF documents for a product and language
        
        Args:
            product: Product ID
            lang: Language code
            
        Returns:
            Exit code (0 = success, non-zero if any PDF failed)
        """
        sections = self.config.get_sections(product)
        failed = []
        
        print(f"📚 Building all PDFs for {product} ({lang})")
        print(f"  Sections: {', '.join(sections)}")
        
        for section in sections:
            result = self.build_section_pdf(product, lang, section)
            if result != 0:
                failed.append(section)
        
        if failed:
            print(f"\n✗ {len(failed)} PDF(s) failed: {', '.join(failed)}")
            return 1
        else:
            print(f"\n✓ All {len(sections)} PDFs built successfully")
            return 0


def main():
    """CLI entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Build PDF documentation')
    parser.add_argument('--product', '-p', default='uyuni',
                       help='Product to build (uyuni, mlm)')
    parser.add_argument('--lang', '-l', default='en',
                       help='Language code (en, ja, ko, zh_CN)')
    parser.add_argument('--section', '-s',
                       help='Specific section to build (builds all if not specified)')
    parser.add_argument('--all', '-a', action='store_true',
                       help='Build all sections')
    
    args = parser.parse_args()
    
    builder = PDFBuilder()
    
    if args.section:
        exit_code = builder.build_section_pdf(
            product=args.product,
            lang=args.lang,
            section=args.section
        )
    else:
        exit_code = builder.build_all_pdfs(
            product=args.product,
            lang=args.lang
        )
    
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
