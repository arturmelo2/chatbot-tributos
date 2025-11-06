"""
Script para carregar documentos (PDFs, TXTs, Markdown) na base vetorial Chroma.
Ideal para popular a base de conhecimento do chatbot de tributos.

Uso:
    python rag/load_knowledge.py
    python rag/load_knowledge.py --clear

Estrutura esperada:
    rag/data/
        ├── leis/
        ├── manuais/
        ├── faqs/
        └── procedimentos/
"""

import glob
import os
import re
import sys
from typing import Iterator, List, Optional, cast

from langchain_community.vectorstores.utils import filter_complex_metadata

# Adiciona o diretório raiz ao path para importar módulos
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from bs4 import BeautifulSoup
from langchain_chroma import Chroma
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain_core.documents import Document
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

from services.config import get_settings


def parse_html_law(file_path: str) -> Document:
    """
    Parse HTML law file and extract clean text with rich metadata.
    
    Args:
        file_path: Path to HTML file
        
    Returns:
        Document with clean text and metadata
    """
    with open(file_path, "r", encoding="utf-8") as f:
        html_content = f.read()
    
    soup = BeautifulSoup(html_content, "html.parser")
    
    # Extract metadata from table
    metadata = {
        "source": os.path.basename(file_path),
        "type": "law",
        "path": os.path.relpath(file_path, "rag/data"),
    }
    
    # Parse metadata table
    table = soup.find("table")
    if table:
        for row in table.find_all("tr"):
            th = row.find("th")
            td = row.find("td")
            if th and td:
                key = th.get_text(strip=True).lower()
                value = td.get_text(strip=True)
                
                # Map Portuguese keys to English
                key_map = {
                    "tipo": "law_type",
                    "número": "number",
                    "ano": "year",
                    "data": "date",
                    "assunto": "subject",
                    "tags": "tags",
                    "situação": "status",
                    "fonte oficial": "url",
                }
                
                mapped_key = key_map.get(key, key)
                if mapped_key in ["tags"]:
                    # ChromaDB não aceita listas em metadata - converter para string
                    metadata[mapped_key] = ", ".join([tag.strip() for tag in value.split(";")])
                else:
                    metadata[mapped_key] = value
    
    # Extract title/ementa
    title_elem = soup.find("h1")
    title = title_elem.get_text(strip=True) if title_elem else ""
    
    ementa_section = soup.find("h2", string=re.compile(r"Ementa", re.I))
    ementa = ""
    if ementa_section and ementa_section.find_next_sibling("p"):
        ementa = ementa_section.find_next_sibling("p").get_text(strip=True)
    
    # Build clean text content
    content_parts = []
    
    if title:
        content_parts.append(f"# {title}\n")
    
    if ementa:
        content_parts.append(f"**Ementa**: {ementa}\n")
    
    # Add metadata summary
    if metadata.get("law_type"):
        content_parts.append(f"**Tipo**: {metadata.get('law_type')}")
    if metadata.get("year"):
        content_parts.append(f"**Ano**: {metadata.get('year')}")
    if metadata.get("status"):
        content_parts.append(f"**Situação**: {metadata.get('status')}")
    if metadata.get("subject"):
        content_parts.append(f"**Assunto**: {metadata.get('subject')}")
    if metadata.get("tags"):
        tags_str = metadata.get("tags") if isinstance(metadata.get("tags"), str) else ", ".join(metadata.get("tags", []))
        content_parts.append(f"**Tags**: {tags_str}")
    
    # Extract main content (skip navigation and footer)
    for container in soup.find_all("div", class_="container"):
        # Skip metadata table sections
        if container.find("table"):
            continue
        # Skip relations section (can be verbose)
        if container.find("h3", string=re.compile(r"Relações", re.I)):
            continue
        
        text = container.get_text(separator="\n", strip=True)
        if text:
            content_parts.append(text)
    
    clean_text = "\n\n".join(content_parts)
    
    return Document(page_content=clean_text, metadata=metadata)


def iter_docs(data_path: str = "rag/data") -> Iterator[Document]:
    """
    Itera sobre todos os documentos em data_path e carrega-os.

    Suporta: .pdf, .txt, .md
    Adiciona metadata['source'] com o nome do arquivo.

    Args:
        data_path: Caminho para a pasta com documentos

    Yields:
        Document objects do LangChain
    """
    if not os.path.exists(data_path):
        print(f"⚠️  Diretório {data_path} não encontrado!")
        print("   Crie a estrutura de pastas:")
        print(f"   {data_path}/")
        print("   ├── leis/")
        print("   ├── manuais/")
        print("   ├── faqs/")
        print("   └── procedimentos/")
        return

    patterns = ["**/*.pdf", "**/*.txt", "**/*.md", "**/*.html"]
    files_found = []

    for pattern in patterns:
        files_found.extend(glob.glob(os.path.join(data_path, pattern), recursive=True))

    if not files_found:
        print(f"⚠️  Nenhum documento encontrado em {data_path}")
        return

    print(f"📂 Encontrados {len(files_found)} arquivo(s)")

    for fp in files_found:
        file_name = os.path.basename(fp)
        relative_path = os.path.relpath(fp, data_path)

        print(f"   📄 Carregando: {relative_path}")

        try:
            if fp.lower().endswith(".pdf"):
                loader = PyPDFLoader(fp)
                docs = loader.load()
                for doc in docs:
                    doc.metadata["source"] = file_name
                    doc.metadata["type"] = "pdf"
                    doc.metadata["path"] = relative_path
                    yield doc

            elif fp.lower().endswith(".html"):
                # Parse HTML law files with BeautifulSoup
                doc = parse_html_law(fp)
                
                # Add category based on folder
                if "faqs" in relative_path.lower():
                    doc.metadata["category"] = "FAQ"
                elif "leis" in relative_path.lower():
                    doc.metadata["category"] = "Lei"
                elif "manuais" in relative_path.lower():
                    doc.metadata["category"] = "Manual"
                elif "procedimentos" in relative_path.lower():
                    doc.metadata["category"] = "Procedimento"
                
                yield doc

            elif fp.lower().endswith((".md", ".txt")):
                # Usa TextLoader para Markdown e TXT
                loader = TextLoader(fp, encoding="utf-8")
                docs = loader.load()
                for doc in docs:
                    doc.metadata["source"] = file_name
                    doc.metadata["type"] = "markdown" if fp.endswith(".md") else "text"
                    doc.metadata["path"] = relative_path
                    
                    # Add category based on folder
                    if "faqs" in relative_path.lower():
                        doc.metadata["category"] = "FAQ"
                        # Extract topic from filename (e.g., FAQ_IPTU.md -> IPTU)
                        topic_match = re.search(r"FAQ[_-](.+)\.(md|txt)", file_name, re.I)
                        if topic_match:
                            doc.metadata["topic"] = topic_match.group(1).replace("_", " ")
                    elif "leis" in relative_path.lower():
                        doc.metadata["category"] = "Lei"
                    elif "manuais" in relative_path.lower():
                        doc.metadata["category"] = "Manual"
                    elif "procedimentos" in relative_path.lower():
                        doc.metadata["category"] = "Procedimento"
                    
                    yield doc

        except Exception as e:
            print(f"   ❌ Erro ao carregar {file_name}: {e}")


def split_documents(
    docs: List[Document], chunk_size: int = 1200, chunk_overlap: int = 300
) -> List[Document]:
    """
    Divide documentos grandes em chunks menores para melhor recuperação.

    Args:
        docs: Lista de documentos
        chunk_size: Tamanho máximo de cada chunk em caracteres
        chunk_overlap: Sobreposição entre chunks consecutivos

    Returns:
        Lista de documentos divididos
    """
    # Custom separators for legal documents
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        length_function=len,
        separators=[
            "\n\n\n",  # Multiple newlines
            "\n\n",    # Paragraph breaks
            "\nArt. ", # Article breaks in laws
            "\n§ ",    # Paragraph breaks in laws
            "\nI - ",  # Item breaks in laws
            "\n## ",   # H2 headers in markdown
            "\n### ",  # H3 headers in markdown
            "\n",      # Single newline
            ". ",      # Sentence breaks
            " ",       # Word breaks
            "",        # Character breaks
        ],
    )

    return cast(List[Document], text_splitter.split_documents(docs))


def load_knowledge(
    data_path: str = "rag/data",
    chroma_dir: Optional[str] = None,
    embedding_model: Optional[str] = None,
    chunk_size: int = 1200,
    chunk_overlap: int = 300,
    clear_existing: bool = False,
):
    """
    Carrega documentos na base vetorial Chroma.

    Args:
        data_path: Caminho para a pasta com documentos
        chroma_dir: Diretório do Chroma (usa .env se None)
        embedding_model: Modelo de embeddings (usa .env se None)
        chunk_size: Tamanho dos chunks
        chunk_overlap: Sobreposição entre chunks
        clear_existing: Se True, apaga a base existente antes de carregar
    """
    print("=" * 70)
    print("🤖 CARREGADOR DE CONHECIMENTO - Chatbot de Tributos Nova Trento/SC")
    print("=" * 70)

    # Configurações
    settings = get_settings()
    chroma_dir = chroma_dir or settings.CHROMA_DIR
    embedding_model = embedding_model or settings.EMBEDDING_MODEL

    print("\n📊 Configurações:")
    print(f"   Dados: {data_path}")
    print(f"   Chroma: {chroma_dir}")
    print(f"   Embeddings: {embedding_model}")
    print(f"   Chunk size: {chunk_size} caracteres")
    print(f"   Overlap: {chunk_overlap} caracteres")

    # Limpar base existente se solicitado (limpa conteúdo do volume montado)
    if clear_existing and os.path.exists(chroma_dir):
        print(f"\n🗑️  Limpando base existente em {chroma_dir}...")
        import errno
        import shutil

        try:
            # Quando é um volume Docker, remover o diretório raiz falha.
            # Nesse caso, removemos apenas o conteúdo interno.
            for entry in os.listdir(chroma_dir):
                full_path = os.path.join(chroma_dir, entry)
                try:
                    if os.path.islink(full_path) or os.path.isfile(full_path):
                        os.unlink(full_path)
                    elif os.path.isdir(full_path):
                        shutil.rmtree(full_path)
                except OSError as e:
                    if e.errno != errno.ENOENT:
                        raise
            print("   ✅ Base limpa")
        except Exception as e:
            print(f"   ❌ Falha ao limpar base: {e}")

    # Criar diretório se não existir
    os.makedirs(chroma_dir, exist_ok=True)

    # Carregar embeddings
    print("\n🔧 Carregando modelo de embeddings...")
    embedding = HuggingFaceEmbeddings(model_name=embedding_model)
    print("   ✅ Modelo carregado")

    # Conectar ao Chroma
    print("\n💾 Conectando ao Chroma...")
    vector_store = Chroma(
        persist_directory=chroma_dir,
        embedding_function=embedding,
    )
    print("   ✅ Conectado")

    # Carregar documentos
    print(f"\n📚 Carregando documentos de {data_path}...")
    docs = list(iter_docs(data_path))

    if not docs:
        print("\n❌ Nenhum documento carregado. Verifique a pasta 'rag/data'.")
        return

    print(f"\n✅ {len(docs)} documento(s) carregado(s)")

    # Dividir documentos em chunks
    print("\n✂️  Dividindo documentos em chunks...")
    chunks = split_documents(docs, chunk_size, chunk_overlap)
    print(f"   ✅ {len(chunks)} chunk(s) criado(s)")

    # Filtrar metadados complexos (listas, dicts, etc) que ChromaDB não aceita
    print("\n🔧 Filtrando metadados complexos...")
    
    # Debug: verificar metadados antes e depois do filtro
    print(f"\n🔍 Debug - Chunk 100 metadata antes do filtro:")
    if len(chunks) >= 100:
        print(f"   {chunks[99].metadata}")
    
    chunks = filter_complex_metadata(chunks)
    
    print(f"\n🔍 Debug - Chunk 100 metadata depois do filtro:")
    if len(chunks) >= 100:
        print(f"   {chunks[99].metadata}")

    # Adicionar ao Chroma
    print("\n💾 Adicionando chunks ao Chroma...")
    batch_size = 100
    for i in range(0, len(chunks), batch_size):
        batch = chunks[i : i + batch_size]
        vector_store.add_documents(batch)
        print(f"   📦 Processados {min(i + batch_size, len(chunks))}/{len(chunks)} chunks")

    print("\n" + "=" * 70)
    print("✅ CONCLUÍDO!")
    print("=" * 70)
    print("\n📊 Estatísticas finais:")
    print(f"   Documentos originais: {len(docs)}")
    print(f"   Chunks gerados: {len(chunks)}")
    print(f"   Base vetorial: {chroma_dir}")
    print(f"\n💡 Dica: Adicione mais documentos em '{data_path}' e execute novamente.")
    print("   Para limpar a base antes: python rag/load_knowledge.py --clear")


def main():
    """Função principal com suporte a argumentos de linha de comando."""
    import argparse

    parser = argparse.ArgumentParser(description="Carrega documentos na base vetorial Chroma")
    parser.add_argument(
        "--data-path",
        default="rag/data",
        help="Caminho para a pasta com documentos (padrão: rag/data)",
    )
    parser.add_argument("--chroma-dir", default=None, help="Diretório do Chroma (padrão: usa .env)")
    parser.add_argument(
        "--embedding-model", default=None, help="Modelo de embeddings (padrão: usa .env)"
    )
    parser.add_argument(
        "--chunk-size",
        type=int,
        default=1200,
        help="Tamanho dos chunks em caracteres (padrão: 1200)",
    )
    parser.add_argument(
        "--chunk-overlap", type=int, default=300, help="Sobreposição entre chunks (padrão: 300)"
    )
    parser.add_argument(
        "--clear", action="store_true", help="Limpa a base existente antes de carregar"
    )

    args = parser.parse_args()

    load_knowledge(
        data_path=args.data_path,
        chroma_dir=args.chroma_dir,
        embedding_model=args.embedding_model,
        chunk_size=args.chunk_size,
        chunk_overlap=args.chunk_overlap,
        clear_existing=args.clear,
    )


if __name__ == "__main__":
    main()
