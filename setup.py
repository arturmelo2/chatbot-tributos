#!/usr/bin/env python3
"""
Setup script para instalação do Chatbot de Tributos.
"""

from setuptools import find_packages, setup

# Ler versão do arquivo
with open("services/version.py", encoding="utf-8") as f:
    for line in f:
        if line.startswith("__version__"):
            version = line.split("=")[1].strip().strip('"').strip("'")
            break

# Ler README
with open("README.md", encoding="utf-8") as f:
    long_description = f.read()

# Ler requirements
with open("requirements.txt", encoding="utf-8") as f:
    requirements = [line.strip() for line in f if line.strip() and not line.startswith("#")]

# Ler requirements-dev
with open("requirements-dev.txt", encoding="utf-8") as f:
    dev_requirements = [line.strip() for line in f if line.strip() and not line.startswith("#")]

setup(
    name="chatbot-tributos",
    version=version,
    description="Sistema de chatbot inteligente para atendimento sobre tributos municipais",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Prefeitura Municipal de Nova Trento/SC",
    author_email="ti@novatrento.sc.gov.br",
    url="https://github.com/arturmelo2/chatbot-tributos",
    project_urls={
        "Bug Reports": "https://github.com/arturmelo2/chatbot-tributos/issues",
        "Source": "https://github.com/arturmelo2/chatbot-tributos",
    },
    packages=find_packages(exclude=["tests", "tests.*", "docs", "scripts"]),
    python_requires=">=3.11",
    install_requires=requirements,
    extras_require={
        "dev": dev_requirements,
    },
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Government",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
        "Topic :: Communications :: Chat",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
    ],
    entry_points={
        "console_scripts": [
            "chatbot-tributos=app:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)
