#!/usr/bin/env python
"""
Script para migrar dados do ChromaDB para Qdrant.

Uso:
    python scripts/migrations/migrate_chroma_to_qdrant.py
    python scripts/migrations/migrate_chroma_to_qdrant.py --chroma-dir ./chroma_data --qdrant-url http://localhost:6333

Requisitos:
    - ChromaDB com dados existentes
    - Qdrant rodando (Docker ou local)
"""

import argparse
import os
import sys
from typing import List

# Adiciona o diretório raiz ao path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))

from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams

from services.config import get_settings


def migrate_chroma_to_qdrant(
    chroma_dir: str,
    qdrant_url: str,
    collection_name: str = "tributos_docs",
    embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2",
    batch_size: int = 100,
):
    """
    Migra dados do ChromaDB para Qdrant.

    Args:
        chroma_dir: Diretório do ChromaDB
        qdrant_url: URL do Qdrant
        collection_name: Nome da collection no Qdrant
        embedding_model: Modelo de embeddings
        batch_size: Tamanho do batch para processamento
    """
    print("=" * 80)
    print("🔄 MIGRAÇÃO: ChromaDB → Qdrant")
    print("=" * 80)

    # Configurações
    print(f"\n📊 Configurações:")
    print(f"   ChromaDB: {chroma_dir}")
    print(f"   Qdrant: {qdrant_url}")
    print(f"   Collection: {collection_name}")
    print(f"   Embeddings: {embedding_model}")
    print(f"   Batch size: {batch_size}")

    # Carregar embeddings
    print("\n🔧 Carregando modelo de embeddings...")
    embedding = HuggingFaceEmbeddings(model_name=embedding_model)
    print("   ✅ Modelo carregado")

    # Conectar ao ChromaDB
    print("\n📥 Conectando ao ChromaDB...")
    if not os.path.exists(chroma_dir):
        print(f"   ❌ Diretório não encontrado: {chroma_dir}")
        return
    
    chroma = Chroma(persist_directory=chroma_dir, embedding_function=embedding)
    print("   ✅ Conectado ao ChromaDB")

    # Buscar todos os documentos
    print("\n📚 Buscando documentos do ChromaDB...")
    try:
        data = chroma.get()
        doc_count = len(data["ids"])
        print(f"   ✅ {doc_count} documentos encontrados")
        
        if doc_count == 0:
            print("\n   ⚠️  ChromaDB está vazio. Nada para migrar.")
            return
        
        # Reconstruir documentos
        print("\n🔨 Reconstruindo documentos...")
        documents: List[Document] = []
        for i in range(doc_count):
            doc = Document(
                page_content=data["documents"][i],
                metadata=data["metadatas"][i] if data["metadatas"] else {},
            )
            documents.append(doc)
        print(f"   ✅ {len(documents)} documentos reconstruídos")
        
    except Exception as e:
        print(f"   ❌ Erro ao buscar documentos: {e}")
        return

    # Conectar ao Qdrant
    print(f"\n📤 Conectando ao Qdrant ({qdrant_url})...")
    try:
        client = QdrantClient(url=qdrant_url)
        print("   ✅ Conectado ao Qdrant")
    except Exception as e:
        print(f"   ❌ Erro ao conectar: {e}")
        print("   💡 Certifique-se de que o Qdrant está rodando:")
        print("      docker compose -f compose.minimal.yml up -d qdrant")
        return

    # Verificar se collection existe
    print(f"\n🔍 Verificando collection '{collection_name}'...")
    try:
        collections = client.get_collections().collections
        collection_exists = any(c.name == collection_name for c in collections)
        
        if collection_exists:
            print(f"   ⚠️  Collection '{collection_name}' já existe")
            response = input("   Deseja deletar e recriar? (s/N): ").strip().lower()
            if response == "s":
                client.delete_collection(collection_name)
                print("   ✅ Collection deletada")
            else:
                print("   ❌ Migração cancelada")
                return
    except Exception as e:
        print(f"   ⚠️  Erro ao verificar collection: {e}")

    # Criar vector store no Qdrant
    print(f"\n💾 Criando collection no Qdrant...")
    try:
        vector_store = QdrantVectorStore.from_documents(
            documents=documents,
            embedding=embedding,
            url=qdrant_url,
            collection_name=collection_name,
            batch_size=batch_size,
        )
        print("   ✅ Documentos migrados com sucesso!")
    except Exception as e:
        print(f"   ❌ Erro ao criar collection: {e}")
        return

    # Verificar migração
    print("\n🔍 Verificando migração...")
    try:
        info = client.get_collection(collection_name)
        print(f"   ✅ Collection criada: {info.points_count} documentos")
        print(f"   ✅ Vector size: {info.config.params.vectors.size}")
        print(f"   ✅ Distance: {info.config.params.vectors.distance}")
    except Exception as e:
        print(f"   ⚠️  Erro ao verificar: {e}")

    print("\n" + "=" * 80)
    print("✅ MIGRAÇÃO CONCLUÍDA!")
    print("=" * 80)
    print(f"\n📊 Resumo:")
    print(f"   Documentos migrados: {doc_count}")
    print(f"   Collection: {collection_name}")
    print(f"   URL: {qdrant_url}")
    print(f"\n💡 Próximos passos:")
    print(f"   1. Atualizar bot/ai_bot.py para usar Qdrant")
    print(f"   2. Atualizar .env com VECTOR_DB=qdrant")
    print(f"   3. Reiniciar API: docker compose restart api")


def main():
    """Função principal com argumentos de linha de comando."""
    parser = argparse.ArgumentParser(
        description="Migra dados do ChromaDB para Qdrant",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  # Usar configurações do .env
  python scripts/migrations/migrate_chroma_to_qdrant.py

  # Especificar diretórios manualmente
  python scripts/migrations/migrate_chroma_to_qdrant.py --chroma-dir ./chroma_data --qdrant-url http://localhost:6333

  # Alterar nome da collection
  python scripts/migrations/migrate_chroma_to_qdrant.py --collection tributos_production
        """,
    )
    
    settings = get_settings()
    
    parser.add_argument(
        "--chroma-dir",
        default=settings.CHROMA_DIR,
        help=f"Diretório do ChromaDB (padrão: {settings.CHROMA_DIR})",
    )
    parser.add_argument(
        "--qdrant-url",
        default="http://localhost:6333",
        help="URL do Qdrant (padrão: http://localhost:6333)",
    )
    parser.add_argument(
        "--collection",
        default="tributos_docs",
        help="Nome da collection no Qdrant (padrão: tributos_docs)",
    )
    parser.add_argument(
        "--embedding-model",
        default=settings.EMBEDDING_MODEL,
        help=f"Modelo de embeddings (padrão: {settings.EMBEDDING_MODEL})",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=100,
        help="Tamanho do batch (padrão: 100)",
    )

    args = parser.parse_args()

    migrate_chroma_to_qdrant(
        chroma_dir=args.chroma_dir,
        qdrant_url=args.qdrant_url,
        collection_name=args.collection,
        embedding_model=args.embedding_model,
        batch_size=args.batch_size,
    )


if __name__ == "__main__":
    main()
