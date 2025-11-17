#!/usr/bin/env python3
"""
Build Configuration Module
Loads and provides access to build parameters from parameters.yml
"""

import yaml
from pathlib import Path
from typing import Dict, List, Any
from dataclasses import dataclass


@dataclass
class LanguageConfig:
    """Configuration for a specific language"""
    langcode: str
    name: str
    locale: str
    date_format: str
    cjk: bool = False
    asciidoctor_flags: str = ""

    @property
    def is_cjk(self) -> bool:
        """Check if this is a CJK language"""
        return self.cjk or self.langcode in ['ja', 'ko', 'zh_CN']
    
    @property
    def pdf_flags(self) -> str:
        """Get PDF-specific asciidoctor flags"""
        flags = self.asciidoctor_flags
        if self.is_cjk and '-a scripts=cjk' not in flags:
            flags = f"{flags} -a scripts=cjk".strip()
        return flags


@dataclass
class ProductConfig:
    """Configuration for a specific product"""
    product_id: str
    name: str
    productname: str
    productnumber: str
    content_flag: str
    filename: str  # PDF filename prefix (e.g., 'suse_multi_linux_manager' or 'uyuni')
    sections: List[str]
    site: Dict[str, Any]
    asciidoc_attributes: Dict[str, Any]


class BuildConfig:
    """Main build configuration manager"""
    
    def __init__(self, config_file: str = './parameters.yml'):
        self.config_file = Path(config_file)
        self._load_config()
    
    def _load_config(self):
        """Load configuration from YAML file"""
        if not self.config_file.exists():
            raise FileNotFoundError(f"Configuration file not found: {self.config_file}")
        
        with open(self.config_file, 'r') as f:
            self.data = yaml.safe_load(f)
        
        # Parse languages
        self.languages = []
        language_names = {
            'en': 'English',
            'ja': 'Japanese',
            'ko': 'Korean',
            'zh_CN': 'Chinese (Simplified)',
            'cs': 'Czech',
            'es': 'Spanish'
        }
        
        for lang_data in self.data.get('languages', []):
            langcode = lang_data['langcode']
            self.languages.append(LanguageConfig(
                langcode=langcode,
                name=lang_data.get('language_in_orig', language_names.get(langcode, langcode)),
                locale=lang_data.get('locale', "{}_{}.UTF-8".format(langcode, langcode.upper())),
                date_format=lang_data.get('gnudateformat', '%B %d %Y'),
                cjk='cjk' in lang_data.get('asciidoctor_pdf_additional_attributes', ''),
                asciidoctor_flags=lang_data.get('asciidoctor_pdf_additional_attributes', '')
            ))
        
        # Parse products
        self.products = {}
        for product_id, product_data in self.data.get('products', {}).items():
            # Extract asciidoc attributes into a dict
            asciidoc_attrs = {}
            for attr in product_data.get('asciidoc', {}).get('attributes', []):
                asciidoc_attrs[attr['attribute']] = attr['value']
            
            # Extract sections
            sections = [s['name'] for s in product_data.get('sections', [])]
            
            self.products[product_id] = ProductConfig(
                product_id=product_id,
                name=product_data.get('antora', {}).get('name', product_id),
                productname=asciidoc_attrs.get('productname', product_id.upper()),
                productnumber=asciidoc_attrs.get('productnumber', '1.0'),
                content_flag=f"{product_id}-content",
                filename=product_data.get('filename', product_id),
                sections=sections,
                site=product_data.get('site', {}),
                asciidoc_attributes=asciidoc_attrs
            )
    
    def get_product(self, product_id: str) -> ProductConfig:
        """Get product configuration by ID"""
        if product_id not in self.products:
            raise ValueError(f"Unknown product: {product_id}. Available: {list(self.products.keys())}")
        return self.products[product_id]
    
    def get_language(self, langcode: str) -> LanguageConfig:
        """Get language configuration by language code"""
        for lang in self.languages:
            if lang.langcode == langcode:
                return lang
        raise ValueError(f"Unknown language: {langcode}. Available: {[l.langcode for l in self.languages]}")
    
    def list_products(self) -> List[str]:
        """List all available product IDs"""
        return list(self.products.keys())
    
    def list_languages(self) -> List[str]:
        """List all available language codes"""
        return [lang.langcode for lang in self.languages]
    
    def get_sections(self, product_id: str) -> List[str]:
        """Get list of documentation sections for a product"""
        product = self.get_product(product_id)
        return product.sections
    
    def get_build_dir(self, langcode: str) -> Path:
        """Get build output directory for a language"""
        return Path('build') / langcode
    
    def get_pdf_dir(self, langcode: str) -> Path:
        """Get PDF output directory for a language"""
        return self.get_build_dir(langcode) / 'pdf'
    
    def get_translations_dir(self, langcode: str) -> Path:
        """Get translations directory for a language"""
        return Path('translations') / langcode


# Singleton instance
_config_instance = None

def get_config(config_file: str = './parameters.yml') -> BuildConfig:
    """Get or create the global configuration instance"""
    global _config_instance
    if _config_instance is None:
        _config_instance = BuildConfig(config_file)
    return _config_instance


if __name__ == '__main__':
    # Test the configuration
    config = get_config()
    
    print("Available Products:")
    for product_id in config.list_products():
        product = config.get_product(product_id)
        print(f"  - {product_id}: {product.productname} {product.productnumber}")
    
    print("\nAvailable Languages:")
    for langcode in config.list_languages():
        lang = config.get_language(langcode)
        print(f"  - {langcode}: {lang.name} (CJK: {lang.is_cjk})")
    
    print("\nUyuni Sections:")
    for section in config.get_sections('uyuni'):
        print(f"  - {section}")
